//
//  CareManager+FeatureContent.swift
//  Allie
//
//  Created by Waqar Malik on 5/27/21.
//

import CareKitStore
import CareModel
import Combine
import SDWebImage
import UIKit

extension CareManager {
	func image(task: OCKAnyTask & AnyTaskExtensible, completion: @escaping AllieResultCompletion<UIImage>) {
		Task.detached(priority: .userInitiated) { [weak self] in
			guard let strongSelf = self else {
				return
			}
			do {
				let image = try await strongSelf.image(task: task)
				completion(.success(image))
			} catch {
				completion(.failure(error))
			}
		}
	}

	func image(task: OCKAnyTask & AnyTaskExtensible) async throws -> UIImage {
		let taskId = task.id
		let carePlanId = activeCarePlan?.id
		guard let patientId = patient?.id, let carePlanId = carePlanId, let asset = task.asset else {
			throw URLError(.unsupportedURL)
		}
		let key = patientId + carePlanId + taskId + asset
		if let image = SDImageCache.shared.imageFromDiskCache(forKey: key) {
			return image
		} else {
			let value = try await networkAPI.getFeatureContent(carePlanId: carePlanId, taskId: taskId, asset: asset)
			return try await image(key: key, url: value.signedURL)
		}
	}

	func image(key: String, url: URL) async throws -> UIImage {
		let image = try await networkAPI.loadImage(url: url)
		return await SDImageCache.shared.store(image: image, forKey: key, toDisk: true) ?? image
	}

	func pdfData(task: OCKAnyTask & AnyTaskExtensible, completion: @escaping AllieResultCompletion<URL>) {
		Task.detached(priority: .userInitiated) { [weak self] in
			guard let strongSelf = self else {
				return
			}
			do {
				let url = try await strongSelf.pdfData(task: task)
				completion(.success(url))
			} catch {
				completion(.failure(error))
			}
		}
	}

	func pdfData(task: OCKAnyTask & AnyTaskExtensible) async throws -> URL {
		let taskId = task.id
		guard let patientId = patient?.id, let carePlanId = activeCarePlan?.id, let asset = task.featuredContentDetailViewAsset else {
			throw URLError(.unsupportedURL)
		}
		guard let url = FileManager.default.documentsFileURL(patientId: patientId, carePlanId: carePlanId, taskId: taskId, name: asset) else {
			throw URLError(.fileDoesNotExist)
		}

		if FileManager.default.fileExists(atPath: url.path) {
			return url
		} else {
			let value = try await networkAPI.getFeatureContent(carePlanId: carePlanId, taskId: taskId, asset: asset)
			let newURL = try await savePDFData(from: value.signedURL, to: url)
			return newURL
		}
	}

	func savePDFData(from: URL, to: URL) async throws -> URL {
		let data = try await networkAPI.getData(url: from)
		let directoryPath = to.deletingLastPathComponent()
		if !FileManager.default.fileExists(atPath: directoryPath.path) {
			try FileManager.default.createDirectory(at: directoryPath, withIntermediateDirectories: true, attributes: nil)
		}
		try data.write(to: to, options: .atomicWrite)
		return to
	}
}
