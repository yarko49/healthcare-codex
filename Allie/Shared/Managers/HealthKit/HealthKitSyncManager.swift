//
//  HealthKitSyncManager.swift
//  Allie
//

import Foundation
import UIKit

class HealthKitSyncManager {
	class func syncData(initialUpload: Bool = true, chunkSize: Int?, progressUpdate: @escaping (Int, Int) -> Void = { _, _ in }, completion: @escaping (Bool) -> Void) {
		guard let chunkSize = chunkSize else {
			completion(false)
			return
		}
		UIApplication.shared.isIdleTimerDisabled = true
		searchHKData(initialUpload: initialUpload) { importSuccess, allEntries in
			UIApplication.shared.isIdleTimerDisabled = false
			if importSuccess {
				UIApplication.shared.isIdleTimerDisabled = true
				progressUpdate(0, allEntries.count)
				self.uploadHKData(with: allEntries, chunkSize: chunkSize, progressUpdate: { uploaded, total in
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

	class func getLatestDate(for quantity: HealthKitDataType, completion: @escaping (Date) -> Void) {
		guard let date = Calendar.current.date(byAdding: .year, value: -1, to: Date()) else {
			completion(Date())
			return
		}
		APIClient.client.postObservationSearch(search: quantity.searchParameter) { result in
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
				ALog.error("Post Observation Search", error: error)
				completion(Date())
			}
		}
	}

	class func searchHKData(initialUpload: Bool = true, completion: @escaping (Bool, [BundleEntry]) -> Void) {
		var allEntries: [BundleEntry] = []
		let importGroup = DispatchGroup()
		guard let date = Calendar.current.date(byAdding: .year, value: -1, to: Date()) else {
			completion(false, allEntries)
			return
		}
		var results: [Bool] = []
		for quantity in HealthKitDataType.allCases {
			importGroup.enter()
			getLatestDate(for: quantity) { searchDate in
				let searchDate = initialUpload ? date : searchDate
				if quantity == .bloodPressure {
					HealthKitManager.shared.queryBloodPressure(initialUpload: initialUpload, from: searchDate) { success, entries in
						results.append(success)
						allEntries += entries
						importGroup.leave()
					}
				} else {
					HealthKitManager.shared.queryHealthData(initialUpload: initialUpload, for: quantity, from: searchDate) { success, entries in
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

	class func uploadHKData(with allEntries: [BundleEntry], chunkSize: Int, progressUpdate: @escaping (Int, Int) -> Void, completion: @escaping (Bool) -> Void) {
		let chunkGroup = DispatchGroup()
		var uploaded = 0
		let chunkedEntries = allEntries.chunked(into: chunkSize)
		let entriesToUploadCount = allEntries.count
		chunkedEntries.enumerated().forEach { index, element in
			let timeOffset: TimeInterval = Double(index) * 1.5
			chunkGroup.enter()
			DispatchQueue.main.asyncAfter(deadline: .now() + timeOffset) {
				self.postBundleRequest(for: element) { success in
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

	private class func postBundleRequest(for entries: [BundleEntry], completion: @escaping (Bool) -> Void) {
		let bundle = CodexBundle(entry: entries, link: nil, resourceType: "Bundle", total: nil, type: "transaction")
		APIClient.client.postBundle(bundle: bundle) { result in
			switch result {
			case .failure(let error):
				ALog.error("Post Bundle", error: error)
				completion(false)
			case .success:
				completion(true)
			}
		}
	}
}
