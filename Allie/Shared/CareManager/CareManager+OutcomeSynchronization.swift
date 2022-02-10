//
//  CareManager+OutcomeSynchronization.swift
//  Allie
//
//  Created by Waqar Malik on 11/28/21.
//

import CareKitStore
import Foundation

extension CareManager {
	func synchronizeCareKitOutcomes() {
		guard patient != nil else {
			return
		}

		uploadQueue.async { [weak self] in
			guard let strongSelf = self else {
				return
			}
			guard !strongSelf.outcomeUploadInProgress else {
				return
			}
			strongSelf.outcomeUploadInProgress = true
			strongSelf.fetchCareKitOutcomes(callbackQueue: strongSelf.uploadQueue) { success in
				if !success {
					ALog.error("Upload failed")
				}
				strongSelf.outcomeUploadInProgress = false
			}
		}
	}

	func fetchCareKitOutcomes() async throws {
		var query = OCKTaskQuery()
		query.sortDescriptors = [.effectiveDate(ascending: false)]
		let newTasks = try await store.fetchTasks(query: query)
		let tasks: [UUID: OCKTask] = newTasks.reduce([:]) { partialResult, task in
			var result = partialResult
			result[task.uuid] = task
			return result
		}
		guard !tasks.isEmpty else {
			return
		}
		let startDate = UserDefaults.outcomeUploadDate
		let endDate = Date()
		let taskUUIDs = Array(tasks.keys)
		let outcomes = try await fetchOutcomes(taskIds: taskUUIDs, startDate: startDate, endDate: endDate)
		guard !outcomes.isEmpty else {
			return
		}
		let filtered = outcomes.filter { outcome in
			do {
				let existing = try dbFindFirst(uuid: outcome.uuid)
				return existing == nil
			} catch {
				return true
			}
		}
		ALog.trace("Outcomes Count \(filtered.count)")
		let chOutcomes = filtered.compactMap { outcome -> CHOutcome? in
			guard let task = tasks[outcome.taskUUID], let carePlanId = task.carePlanId else {
				return nil
			}

			return CHOutcome(outcome: outcome, carePlanID: carePlanId, task: task)
		}

		let uploadedOutcomes = try await upload(outcomes: chOutcomes)
		ALog.trace("Uploaded outcomes \(uploadedOutcomes.count)")
		UserDefaults.outcomeUploadDate = endDate
	}

	func fetchCareKitOutcomes(callbackQueue: DispatchQueue, completion: @escaping AllieBoolCompletion) {
		var query = OCKTaskQuery()
		query.sortDescriptors = [.effectiveDate(ascending: false)]
		store.fetchTasks(query: query, callbackQueue: callbackQueue) { [weak self] tasksResult in
			switch tasksResult {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
				completion(false)
			case .success(let newTasks):
				let tasks: [UUID: OCKTask] = newTasks.reduce([:]) { partialResult, task in
					var result = partialResult
					result[task.uuid] = task
					return result
				}
				guard !tasks.isEmpty else {
					completion(true)
					return
				}
				let startDate = UserDefaults.outcomeUploadDate
				let endDate = Date()
				let taskUUIDs = Array(tasks.keys)

				self?.fetchOutcomes(taskIds: taskUUIDs, startDate: startDate, endDate: endDate, callbackQueue: callbackQueue, completion: { outcomsResult in
					switch outcomsResult {
					case .failure(let error):
						ALog.error("No outcomes found", error: error)
						completion(false)
					case .success(let outcomes):
						guard !outcomes.isEmpty else {
							completion(true)
							return
						}
						let filtered = outcomes.filter { outcome in
							do {
								let existing = try self?.dbFindFirst(uuid: outcome.uuid)
								return existing == nil
							} catch {
								return true
							}
						}
						ALog.trace("Outcomes Count \(filtered.count)")
						let chOutcomes = filtered.compactMap { outcome -> CHOutcome? in
							guard let task = tasks[outcome.taskUUID], let carePlanId = task.carePlanId else {
								return nil
							}

							return CHOutcome(outcome: outcome, carePlanID: carePlanId, task: task)
						}

						self?.upload(outcomes: chOutcomes) { uploadResult in
							switch uploadResult {
							case .failure(let error):
								ALog.error("Error uploading outcomes", error: error)
								completion(false)
							case .success(let uploadedOutcomes):
								ALog.trace("Uploaded outcomes \(uploadedOutcomes.count)")
								UserDefaults.outcomeUploadDate = endDate
								completion(true)
							}
						}
					}
				})
			}
		}
	}
}
