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
		guard let carePlanId = task.carePlanId, let asset = task.asset else {
			completion(.failure(URLError(.unsupportedURL)))
			return
		}
		let taskId = task.id
		let key = carePlanId + taskId + asset
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
}
