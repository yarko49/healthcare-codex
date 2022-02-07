//
//  NewDailyPageViewModel.swift
//  Allie
//
//  Created by Onseen on 1/31/22.
//

import Foundation
import Combine
import CareKitStore
import CareKit
import HealthKit
import CareKitUI
import UIKit

class NewDailyTasksPageViewModel: ObservableObject {
    @Injected(\.careManager) var careManager: CareManager
    @Injected(\.healthKitManager) var healthKitManager: HealthKitManager
    @Published public internal(set) var error: Error?
    @Published var timelineItemViewModels = [TimelineItemViewModel]()

    public let storeManager: OCKSynchronizedStoreManager = CareManager.shared.synchronizedStoreManager
    private var cancellables: Set<AnyCancellable> = []
    private var taskCanceellables: [String: Set<AnyCancellable>] = [:]

    func loadHealthData(date: Date) {
        var query = OCKTaskQuery(for: date)
        query.excludesTasksWithNoEvents = true
        storeManager.store.fetchAnyTasks(query: query, callbackQueue: .main) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .failure(let error):
                ALog.error("Fetching tasks for care plans", error: error)
            case .success(let tasks):
                let filtered = tasks.filter { task in
                    if let chTask = self.careManager.tasks[task.id] {
                        return !chTask.isDeleted(for: date) && task.schedule.exists(onDay: date)
                    } else if let ockTask = task as? OCKTask {
                        return !ockTask.isDeleted(for: date) && task.schedule.exists(onDay: date)
                    } else if let hkTask = task as? OCKHealthKitTask, let deletedDate = hkTask.deletedDate {
                        return deletedDate.shouldShow(for: date)
                    } else {
                        return true
                    }
                }
                let sorted = filtered.sorted { lhs, rhs in
                    guard let left = lhs as? AnyTaskExtensible, let right = rhs as? AnyTaskExtensible else {
                        return false
                    }
                    return left.priority < right.priority
                }
                self.fetchAndObserveEvents(tasks: sorted, query: OCKEventQuery(for: date))
            }
        }
    }

    func fetchAndObserveEvents(tasks: [OCKAnyTask], query: OCKEventQuery) {
        let ids = Array(Set(tasks.map { $0.id }))
        storeManager.fetchEventsPublisher(taskIDs: ids, query: query) { [unowned self] error in
            self.error = error
        }
        .sink { [unowned self] events in
            self.generateTimelineItems(events: events)
        }
        .store(in: &cancellables)
    }

    func generateTimelineItems(events: [[OCKAnyEvent]]) {
        var items = [TimelineItemViewModel]()
        for taskEvent in events {
            var flag = false
            for event in taskEvent {
                if let outcomes = event.outcome {
                    if !outcomes.values.isEmpty {
                        var outcomeArr = [OCKOutcomeValue]()
                        var healthKitUUID = outcomes.values.first?.healthKitUUID
                        for outcome in outcomes.values {
                            if outcome.healthKitUUID == healthKitUUID && outcome.healthKitUUID != nil {
                                outcomeArr.append(outcome)
                                continue
                            } else {
                                healthKitUUID = outcome.healthKitUUID
                                if !outcomeArr.isEmpty {
                                    items.append(TimelineItemViewModel(timelineItemModel: TimelineItemModel(outcomeValues: outcomeArr, event: event)))
                                }
                                outcomeArr.removeAll()
                                outcomeArr.append(outcome)
                            }
                        }
                        items.append(TimelineItemViewModel(timelineItemModel: TimelineItemModel(outcomeValues: outcomeArr, event: event)))
                        flag = true
                    } else if !flag {
                        let timelineItemModel = TimelineItemModel(outcomeValues: nil, event: event)
                        items.append(TimelineItemViewModel(timelineItemModel: timelineItemModel))
                        flag = true
                    }
                } else if !flag {
                    let timelineItemModel = TimelineItemModel(outcomeValues: nil, event: event)
                    items.append(TimelineItemViewModel(timelineItemModel: timelineItemModel))
                    flag = true
                }
            }
        }

       timelineItemViewModels = items.sorted { lhs, rhs in
            let date1 = lhs.dateTime
            let date2 = rhs.dateTime
            if lhs.hasOutcomeValue() && !rhs.hasOutcomeValue() {
                return true
            }
            if !lhs.hasOutcomeValue() && rhs.hasOutcomeValue() {
                return false
            }
            return date1.compare(date2) == .orderedAscending
        }
    }

    func modified(event: OCKAnyEvent) -> OCKAnyEvent {
        return event
    }

    func clearSubscriptions() {
        cancellables = []
        taskCanceellables = [:]
    }

    func deleteOutcom(value: OCKOutcomeValue, task: OCKHealthKitTask, completion: @escaping AllieResultCompletion<CHOutcome>) {
        deleteOutcome(value: value) { [weak self] result in
            switch result {
            case .success(let sample):
                ALog.trace("Did delete sample \(sample.uuid)", metadata: nil)
                do {
                    var outcome: CHOutcome?
                    if let carePlanId = task.carePlanId {
                        outcome = self?.careManager.fetchOutcome(sample: sample, deletedSample: sample, task: task, carePlanId: carePlanId)
                    } else {
                        outcome = try self?.careManager.dbFindFirstOutcome(sample: sample)
                    }
                    guard var existingOutcome = outcome else {
                        throw AllieError.missing("\(sample.uuid.uuidString)")
                    }
                    existingOutcome.deletedDate = Date()
                    self?.careManager.upload(outcomes: [existingOutcome], completion: { result in
                        if case .failure(let error) = result {
                            ALog.error("unable to upload outcome", error: error)
                        }
                        completion(.success(existingOutcome))
                    })
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                ALog.error("Error deleteing data", error: error)
            }
        }
    }

    func deleteOutcome(value: OCKOutcomeValue, completion: AllieResultCompletion<HKSample>?) {
        guard let uuid = value.healthKitUUID, let identifier = value.quantityIdentifier else {
            completion?(.failure(AllieError.invalid("Invalid outcome value")))
            return
        }
        if identifier == HKQuantityTypeIdentifier.bloodPressureSystolic.rawValue || identifier ==
            HKQuantityTypeIdentifier.bloodPressureDiastolic.rawValue {
            guard let bloodPressureType = HKCorrelationType.correlationType(forIdentifier: .bloodPressure) else {
                completion?(.failure(HealthKitManagerError.invalidInput("Invalid quantityIdentifier")))
                return
            }
            healthKitManager.deleteCorrelationSample(uuid: uuid, sampleType: bloodPressureType, completion: completion)
        } else {
            healthKitManager.delete(uuid: uuid, quantityIdentifier: identifier, completion: completion)
        }
    }

    func deleteOutcomeValue(at index: Int, for outcome: OCKOutcome, task: OCKTask, completion: AllieResultCompletion<CHOutcome>?) {
        deleteOutcomeValue(at: index, for: outcome) { [weak self] result in
            switch result {
            case .success(let deletedOutcome):
                guard let deleted = deletedOutcome as? OCKOutcome, let carePlanId = task.carePlanId else {
                    completion?(.failure(AllieError.invalid("Outcome type is wrong")))
                    return
                }
                var chOutcome = CHOutcome(outcome: deleted, carePlanID: carePlanId, task: task)
                chOutcome.deletedDate = Date()
                if let existing = try? self?.careManager.dbFindFirstOutcome(uuid: outcome.uuid) {
                    chOutcome.remoteId = existing.remoteId
                    chOutcome.createdDate = existing.createdDate
                    chOutcome.effectiveDate = existing.effectiveDate
                }
                self?.careManager.upload(outcomes: [chOutcome], completion: { result in
                    switch result {
                    case .failure(let error):
                        ALog.error("unable to upload outcome", error: error)
                        completion?(.failure(error))
                    case .success(let uploadedResponse):
                        completion?(.success(uploadedResponse[0]))
                    }
                })
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }

    func deleteOutcomeValue(at index: Int, for outcome: OCKAnyOutcome, completion: ((Result<OCKAnyOutcome, Error>) -> Void)?) {
        guard outcome.values.count > 1 else {
            storeManager.store.deleteAnyOutcome(outcome, callbackQueue: .main) { result in
                completion?(result.mapError { $0 as Error })
            }
            return
        }
        var newOutcome = outcome
        newOutcome.values.remove(at: index)
        storeManager.store.updateAnyOutcome(newOutcome, callbackQueue: .main) { result in
            completion?(result.mapError { $0 as Error })
        }
    }

    func updateOutcome(newSample: HKSample, outcomeValue: OCKOutcomeValue, task: OCKHealthKitTask, completion: AllieResultCompletion<HKSample?>?) {
        healthKitManager.save(sample: newSample) { [weak self] result in
            switch result {
            case .success:
                self?.deleteOutcome(value: outcomeValue, completion: { result in
                    switch result {
                    case .success(let deletedSample):
                        let lastOutcomeUploadDate = UserDefaults.standard[healthKitOutcomesUploadDate: task.healthKitLinkage.quantityIdentifier.rawValue]
                        if let carePlanId = task.carePlanId, newSample.startDate < lastOutcomeUploadDate, let outcome = self?.careManager.fetchOutcome(sample: newSample, deletedSample: deletedSample, task: task, carePlanId: carePlanId) {
                            self?.careManager.upload(outcomes: [outcome], completion: { result in
                                if case .failure(let error) = result {
                                    ALog.error("unable to upload outcome", error: error)
                                    completion?(.failure(error))
                                } else {
                                    completion?(.success(nil))
                                }
                            })
                        }
                    case .failure(let error):
                        ALog.error("Error deleting data", error: error)
                        completion?(.failure(error))
                    }
                })
            case .failure(let error):
                ALog.error("Unable to save sample", error: error)
                completion?(.failure(error))
            }
        }
    }

    func updateOutcomeValue(newValue: OCKOutcomeValue, for outcome: OCKOutcome, event: OCKAnyEvent, at index: Int, task: OCKTask, completion: AllieResultCompletion<CHOutcome>?) {
        updateOutcomeValue(newValue: newValue, event: event, at: index) { [weak self] result in
            switch result {
            case .success(let updatedOutcome):
                guard var updated = updatedOutcome as? OCKOutcome, let carePlanId = task.carePlanId else {
                    ALog.error("outcome type is wrong")
                    completion?(.failure(AllieError.forbidden("Unable t o update outcome \(outcome.uuid)")))
                    return
                }
                updated.values = [newValue]
                var chOutcome = CHOutcome(outcome: updated, carePlanID: carePlanId, task: task)
                chOutcome.updatedDate = Date()
                chOutcome.createdDate = newValue.createdDate
                chOutcome.effectiveDate = newValue.createdDate
                if let existing = try? self?.careManager.dbFindFirstOutcome(uuid: outcome.uuid) {
                    chOutcome.remoteId = existing.remoteId
                }
                self?.careManager.upload(outcomes: [chOutcome], completion: { result in
                    switch result {
                    case .success(let uploaded):
                        completion?(.success(uploaded[0]))
                    case .failure(let error):
                        completion?(.failure(error))
                    }
                })
            case .failure(let error):
                ALog.error("unable to update outcome value", error: error)
                completion?(.failure(error))
            }
        }
    }

    func updateOutcomeValue(newValue: OCKOutcomeValue, event: OCKAnyEvent, at index: Int, completion: ((Result<OCKAnyOutcome, Error>) -> Void)?) {
        if var eventOutcome = event.outcome {
            if index < eventOutcome.values.count {
                eventOutcome.values[index] = newValue
            } else {
                eventOutcome.values.append(newValue)
            }
            storeManager.store.updateAnyOutcome(eventOutcome, callbackQueue: .main) { result in
                completion?(result.mapError { $0 as Error })
            }
        } else {
            if let outcome = makeOutcomeFor(event: event, withValues: [newValue]) {
                storeManager.store.addAnyOutcome(outcome, callbackQueue: .main) { result in
                    completion?(result.mapError { $0 as Error })
                }
            } else {
                ALog.error("can not make outcome data")
            }
        }
    }

    func addOutcomeValue(newValue: OCKOutcomeValue, carePlanId: String, task: OCKTask, event: OCKAnyEvent, completion: AllieResultCompletion<CHOutcome>?) {
        addOutcomeValue(newValue: newValue, event: event) { [weak self] result in
            guard let strongSelf = self else {
                completion?(.failure(AllieError.forbidden("Self is deallocated")))
                return
            }
            switch result {
            case .failure(let error):
                ALog.error("Error adding outcome", error: error)
                completion?(.failure(error))
            case .success(let outcome):
                guard var ockOutcome = outcome as? OCKOutcome else {
                    completion?(.failure(AllieError.invalid("Added outcome is wrong type")))
                    return
                }
                ockOutcome.values = [newValue]
                var chOutcome = CHOutcome(outcome: ockOutcome, carePlanID: carePlanId, task: task)
                chOutcome.remoteId = nil
                chOutcome.createdDate = newValue.createdDate
                chOutcome.effectiveDate = newValue.createdDate
                strongSelf.careManager.upload(outcomes: [chOutcome]) { result in
                    switch result {
                    case .success(let uploaded):
                        completion?(.success(uploaded[0]))
                    case .failure(let error):
                        completion?(.failure(error))
                    }
                }
            }
        }
    }

    func addOutcomeValue(newValue: OCKOutcomeValue, event: OCKAnyEvent, completion: ((Result<OCKAnyOutcome, Error>) -> Void)?) {
        if var outcome = event.outcome {
            outcome.values.append(newValue)
            storeManager.store.updateAnyOutcome(outcome, callbackQueue: .main) { result in
                completion?(result.mapError { $0 as Error })
            }
        } else {
            if let outcome = makeOutcomeFor(event: event, withValues: [newValue]) {
                storeManager.store.addAnyOutcome(outcome, callbackQueue: .main) { result in
                    completion?(result.mapError { $0 as Error })
                }
            } else {
                ALog.error("can not make outcome data")
            }
        }
    }

    func addOutcome(newValue: HKSample, task: OCKHealthKitTask, completion: AllieResultCompletion<HKSample?>?) {
        healthKitManager.save(sample: newValue) { [weak self] result in
            print(newValue.startDate)
            switch result {
            case .failure(let error):
                ALog.error("Unable to save sample", error: error)
                completion?(.failure(error))
            case .success:
                let lastOutcomeUploadDate = UserDefaults.standard[healthKitOutcomesUploadDate: task.healthKitLinkage.quantityIdentifier.rawValue]
                if let carePlanId = task.carePlanId, newValue.startDate < lastOutcomeUploadDate, let outcome = self?.careManager.fetchOutcome(sample: newValue, deletedSample: nil, task: task, carePlanId: carePlanId) {
                    self?.careManager.upload(outcomes: [outcome]) { result in
                        if case .failure(let error) = result {
                            ALog.error("unable to upload outcome", error: error)
                            completion?(.failure(error))
                        } else {
                            completion?(.success(nil))
                        }
                    }
                } else {
                    completion?(.success(nil))
                }
            }
        }
    }

    func makeOutcomeFor(event: OCKAnyEvent, withValues values: [OCKOutcomeValue]) -> OCKAnyOutcome? {
        guard let task = event.task as? OCKAnyVersionableTask else {
            return nil
        }
        return OCKOutcome(taskUUID: task.uuid, taskOccurrenceIndex: event.scheduleEvent.occurrence, values: values)
    }
}

extension OCKSynchronizedStoreManager {
    func fetchEventsPublisher(taskIDs: [String], query: OCKEventQuery, errorHandler: ((OCKStoreError) -> Void)?) -> AnyPublisher<[[OCKAnyEvent]], Never> {
        let publishers = taskIDs.map { id in
            fetchAnyEventsPublisher(taskID: id, query: query)
                .catch { error -> Empty<[OCKAnyEvent], Never> in
                    errorHandler?(error)
                    return .init()
                }
        }
        return Publishers.Sequence(sequence: publishers)
            .flatMap { $0 }
            .collect()
            .eraseToAnyPublisher()
    }

    func fetchAnyEventsPublisher(taskID: String, query: OCKEventQuery) -> AnyPublisher<[OCKAnyEvent], OCKStoreError> {
        Future { [unowned self] completion in
            self.store.fetchAnyEvents(taskID: taskID, query: query, callbackQueue: .main, completion: completion)
        }
        .eraseToAnyPublisher()
    }
}
