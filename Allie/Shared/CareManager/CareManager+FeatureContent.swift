//
//  CareManager+FeatureContent.swift
//  Allie
//
//  Created by Waqar Malik on 5/27/21.
//

import CareKitStore
import SDWebImage
import UIKit

extension CareManager {
	func image(task: OCKAnyTask & AnyTaskExtensible, completion: @escaping AllieResultCompletion<UIImage>) {
		guard let patientId = patient?.id, let carePlanId = task.carePlanId, let asset = task.asset else {
			completion(.failure(URLError(.unsupportedURL)))
			return
		}
		let taskId = task.id
		let key = patientId + carePlanId + taskId + asset
		if let image = SDImageCache.shared.imageFromDiskCache(forKey: key) {
			completion(.success(image))
		} else {
			APIClient.shared.getFeatureContent(carePlanId: carePlanId, taskId: taskId, asset: asset)
				.sink { completionResult in
					switch completionResult {
					case .failure(let error):
						completion(.failure(error))
					case .finished:
						break
					}
				} receiveValue: { [weak self] value in
					self?.image(key: key, url: value.signedURL, completion: completion)
				}.store(in: &cancellables)
		}
	}

	func image(key: String, url: URL, completion: @escaping AllieResultCompletion<UIImage>) {
		APIClient.shared.loadImage(url: url) { result in
			switch result {
			case .failure(let error):
				completion(.failure(error))
			case .success(let image):
				SDImageCache.shared.store(image, forKey: key, toDisk: true) {
					completion(.success(image))
				}
			}
		}
	}

	func pdfData(task: OCKAnyTask & AnyTaskExtensible, completion: @escaping AllieResultCompletion<URL>) {
		guard let patientId = patient?.id, let carePlanId = task.carePlanId, let asset = task.featuredContentDetailViewAsset else {
			completion(.failure(URLError(.unsupportedURL)))
			return
		}
		let taskId = task.id
		guard let url = FileManager.default.documentsFileURL(patientId: patientId, carePlanId: carePlanId, taskId: taskId, name: asset) else {
			completion(.failure(URLError(.fileDoesNotExist)))
			return
		}

		if FileManager.default.fileExists(atPath: url.path) {
			completion(.success(url))
		} else {
			APIClient.shared.getFeatureContent(carePlanId: carePlanId, taskId: taskId, asset: asset)
				.sink { completionResult in
					switch completionResult {
					case .failure(let error):
						completion(.failure(error))
					case .finished:
						break
					}
				} receiveValue: { [weak self] value in
					self?.savePDFData(from: value.signedURL, to: url, completion: completion)
				}.store(in: &cancellables)
		}
	}

	func savePDFData(from: URL, to: URL, completion: @escaping AllieResultCompletion<URL>) {
		APIClient.shared.getData(url: from)
			.sink { completionResult in
				switch completionResult {
				case .failure(let error):
					completion(.failure(error))
				case .finished:
					break
				}
			} receiveValue: { data in
				do {
					let directoryPath = to.deletingLastPathComponent()
					if !FileManager.default.fileExists(atPath: directoryPath.path) {
						try FileManager.default.createDirectory(at: directoryPath, withIntermediateDirectories: true, attributes: nil)
					}
					try data.write(to: to, options: .atomicWrite)
					completion(.success(to))
				} catch {
					completion(.failure(error))
				}
			}.store(in: &cancellables)
	}
}
