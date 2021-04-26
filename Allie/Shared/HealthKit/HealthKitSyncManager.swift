//
//  HealthKitSyncManager.swift
//  Allie
//

import Foundation
import HealthKit
import ModelsR4
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

	class func syncDataBackground(initialUpload: Bool = true, chunkSize: Int?, progressUpdate: @escaping (Int, Int) -> Void = { _, _ in }, completion: @escaping (Bool) -> Void) {
		guard let chunkSize = chunkSize else {
			completion(false)
			return
		}

		searchHKData(initialUpload: initialUpload) { importSuccess, allEntries in
			if importSuccess {
				progressUpdate(0, allEntries.count)
				self.uploadHKData(with: allEntries, chunkSize: chunkSize, progressUpdate: { uploaded, total in
					progressUpdate(uploaded, total)
				}, completion: { success in
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
	}

	class func searchHKData(initialUpload: Bool = true, completion: @escaping (Bool, [ModelsR4.BundleEntry]) -> Void) {
		var samples: [HKSample] = []
		let importGroup = DispatchGroup()
		guard let date = Calendar.current.date(byAdding: .year, value: -1, to: Date()) else {
			completion(false, [])
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
						samples += entries
						importGroup.leave()
					}
				} else {
					HealthKitManager.shared.queryHealthData(initialUpload: initialUpload, dataType: quantity, from: searchDate) { success, entries in
						results.append(success)
						samples += entries
						importGroup.leave()
					}
				}
			}
		}

		var entries: [ModelsR4.BundleEntry] = []
		do {
			let observationFactory = try ObservationFactory()
			entries = try samples.compactMap { sample in
				let observation = try observationFactory.observation(from: sample)
				let subject = AppDelegate.careManager.patient?.subject
				observation.subject = subject
				let route = APIRouter.postObservation(observation: observation)
				let observationPath = route.path
				let request = ModelsR4.BundleEntryRequest(method: FHIRPrimitive<HTTPVerb>(HTTPVerb.POST), url: FHIRPrimitive<FHIRURI>(stringLiteral: observationPath))
				let fullURL = FHIRPrimitive<FHIRURI>(stringLiteral: APIRouter.baseURLPath + observationPath)
				return ModelsR4.BundleEntry(extension: nil, fullUrl: fullURL, id: nil, link: nil, modifierExtension: nil, request: request, resource: .observation(observation), response: nil, search: nil)
			}
		} catch {
			ALog.error("\(error.localizedDescription)")
		}
		importGroup.notify(queue: .main) {
			completion(results.allSatisfy { $0 }, entries)
		}
	}

	class func uploadHKData(with allEntries: [ModelsR4.BundleEntry], chunkSize: Int, progressUpdate: @escaping (Int, Int) -> Void, completion: @escaping (Bool) -> Void) {
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

	private class func postBundleRequest(for entries: [ModelsR4.BundleEntry], completion: @escaping (Bool) -> Void) {
		let bundle = ModelsR4.Bundle(entry: entries, type: FHIRPrimitive<BundleType>(.transaction))
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
