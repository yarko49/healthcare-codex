//
//  SyncManager.swift
//  Alfred
//

import Foundation
import os.log
import UIKit

extension OSLog {
	static let syncManager = OSLog(subsystem: subsystem, category: "SyncManager")
}

class SyncManager {
	static let shared = SyncManager()

	func syncData(initialUpload: Bool = true, chunkSize: Int?, progressUpdate: @escaping (Int, Int) -> Void = { _, _ in }, completion: @escaping (Bool) -> Void) {
		guard let chunkSize = chunkSize else {
			completion(false)
			return
		}
		UIApplication.shared.isIdleTimerDisabled = true
		searchHKData(initialUpload: initialUpload) { [weak self] importSuccess, allEntries in
			UIApplication.shared.isIdleTimerDisabled = false
			if importSuccess {
				UIApplication.shared.isIdleTimerDisabled = true
				progressUpdate(0, allEntries.count)
				self?.uploadHKData(with: allEntries, chunkSize: chunkSize, progressUpdate: { uploaded, total in
					progressUpdate(uploaded, total)
				}, completion: { success in
					UIApplication.shared.isIdleTimerDisabled = false
					completion(success)
				})
			} else {
				completion(importSuccess)
			}
		}
	}

	func getLatestDate(for quantity: HealthKitDataType, completion: @escaping (Date) -> Void) {
		var search: SearchParameter?
		guard let date = Calendar.current.date(byAdding: .year, value: -1, to: Date()) else {
			completion(Date())
			return
		}
		switch quantity {
		case .bodyMass:
			search = SearchParameter(sort: "-date", count: 1, code: DataContext.shared.weightCode.coding?.first?.code)
		case .stepCount:
			search = SearchParameter(sort: "-date", count: 1, code: DataContext.shared.stepsCode.coding?.first?.code)
		case .bloodPressure:
			search = SearchParameter(sort: "-date", count: 1, code: DataContext.shared.bpCode.coding?.first?.code)
		case .restingHeartRate:
			search = SearchParameter(sort: "-date", count: 1, code: DataContext.shared.restingHRCode.coding?.first?.code)
		case .heartRate:
			search = SearchParameter(sort: "-date", count: 1, code: DataContext.shared.hrCode.coding?.first?.code)
		}
		if let search = search {
			AlfredClient.client.postObservationSearch(search: search) { result in
				switch result {
				case .success(let response):
					if let stringDate = response.entry?.first?.resource?.effectiveDateTime, var searchDate = DateFormatter.wholeDateRequest.date(from: stringDate) {
						searchDate.addTimeInterval(60)
						completion(searchDate)
					} else if response.entry == nil {
						completion(date)
					} else {
						completion(Date())
					}
				case .failure(let error):
					os_log(.error, log: .syncManager, "Post Observation Search %@", error.localizedDescription)
					completion(Date())
				}
			}
		}
	}

	func searchHKData(initialUpload: Bool = true, completion: @escaping (Bool, [Entry]) -> Void) {
		var allEntries: [Entry] = []
		let importGroup = DispatchGroup()
		guard let date = Calendar.current.date(byAdding: .year, value: -1, to: Date()) else {
			completion(false, allEntries)
			return
		}
		var results: [Bool] = []
		for quantity in HealthKitDataType.allValues {
			importGroup.enter()
			getLatestDate(for: quantity) { searchDate in
				let searchDate = initialUpload ? date : searchDate
				if quantity == .bloodPressure {
					HealthKitManager.shared.getBloodPressure(initialUpload: initialUpload, from: searchDate) { success, entries in
						results.append(success)
						allEntries += entries
						importGroup.leave()
					}
				} else {
					HealthKitManager.shared.getHealthData(initialUpload: initialUpload, for: quantity, from: searchDate) { success, entries in
						results.append(success)
						allEntries += entries
						importGroup.leave()
					}
				}
			}
		}
		importGroup.notify(queue: .main) {
			completion(results.allSatisfy { $0 }, allEntries)
		}
	}

	func uploadHKData(with allEntries: [Entry], chunkSize: Int, progressUpdate: @escaping (Int, Int) -> Void, completion: @escaping (Bool) -> Void) {
		let chunkGroup = DispatchGroup()
		var uploaded = 0
		let chunkedEntries = allEntries.chunked(into: chunkSize)
		let entriesToUploadCount = allEntries.count
		chunkedEntries.enumerated().forEach { index, element in
			let timeOffset: TimeInterval = Double(index) * 1.5
			chunkGroup.enter()
			DispatchQueue.main.asyncAfter(deadline: .now() + timeOffset) { [weak self] in
				self?.postBundleRequest(for: element) { success in
					uploaded += success ? element.count : 0
					progressUpdate(uploaded, entriesToUploadCount)
					chunkGroup.leave()
				}
			}
		}
		chunkGroup.notify(queue: .main) {
			if uploaded < entriesToUploadCount {
				let okAction = AlertHelper.AlertAction(withTitle: Str.ok)
				AlertHelper.showAlert(title: Str.error, detailText: Str.uploadHealthDataFailed, actions: [okAction])
			}
			completion(true)
		}
	}

	private func postBundleRequest(for entries: [Entry], completion: @escaping (Bool) -> Void) {
		let bundle = BundleModel(entry: entries, link: nil, resourceType: "Bundle", total: nil, type: "transaction")
		AlfredClient.client.postBundle(bundle: bundle) { result in
			switch result {
			case .failure(let error):
				os_log(.error, log: .syncManager, "Post Bundle %@", error.localizedDescription)
				completion(false)
			case .success:
				completion(true)
			}
		}
	}
}
