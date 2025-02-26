//
//  CareManager+FeatureContent.swift
//  Allie
//
//  Created by Waqar Malik on 5/27/21.
//

import CareKitStore
import Combine
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
			networkAPI.getFeatureContent(carePlanId: carePlanId, taskId: taskId, asset: asset)
				.sink { completionResult in
					if case .failure(let error) = completionResult {
						completion(.failure(error))
					}
				} receiveValue: { [weak self] value in
					self?.image(key: key, url: value.signedURL, completion: completion)
				}.store(in: &cancellables)
		}
	}

	func image(key: String, url: URL, completion: @escaping AllieResultCompletion<UIImage>) {
		networkAPI.loadImage(url: url)
			.sink(receiveCompletion: { result in
				if case .failure(let error) = result {
					completion(.failure(error))
				}
			}, receiveValue: { image in
				SDImageCache.shared.store(image, forKey: key, toDisk: true) {
					completion(.success(image))
				}
			}).store(in: &cancellables)
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
			networkAPI.getFeatureContent(carePlanId: carePlanId, taskId: taskId, asset: asset)
				.sink { completionResult in
					if case .failure(let error) = completionResult {
						completion(.failure(error))
					}
				} receiveValue: { [weak self] value in
					self?.savePDFData(from: value.signedURL, to: url, completion: completion)
				}.store(in: &cancellables)
		}
	}

	func savePDFData(from: URL, to: URL, completion: @escaping AllieResultCompletion<URL>) {
		networkAPI.getData(url: from)
			.sink { completionResult in
				if case .failure(let error) = completionResult {
					completion(.failure(error))
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

	/*
	    networkService.request(.login(username: username, password: password))
	    .flatMap { token in
	    networkService.request(.playlists(token))
	    }.flatMap { playlists in
	    let playlist = playlists.first
	    networkService.request(.songs(for: playlist.id))
	    }.sink(receiveCompletion: {  _ in
	    UIApplication.shared.isNetworkActivityIndicatorVisible = false
	    }, receiveValue: { songs in
	    self.configure(with: songs)
	    }
	 */
}
