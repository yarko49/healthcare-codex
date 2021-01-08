//
//  WebService+Image.swift
//  Alfred
//
//  Created by Waqar Malik on 12/13/20.
//

import UIKit

public extension WebService {
	@discardableResult
	func loadImage(urlString: String, completion: @escaping RequestCompletion<UIImage>) -> URLSession.ServicePublisher? {
		guard let url = URL(string: urlString) else {
			completion(.failure(URLError(.badURL)))
			return nil
		}

		let publisher = session.servicePublisher(for: url)
			.setHeaderValue(Request.ContentType.jpeg, forName: Request.Header.contentType)
		publisher
			.retry(configuration.retryCountForResource)
			.tryMap { result -> Data in
				try result.data.ws_validate(result.response).ws_validate()
			}.tryMap { data -> UIImage in
				guard let image = UIImage(data: data) else {
					throw URLError(.cannotDecodeContentData)
				}
				return image
			}.subscribe(on: DispatchQueue.global(qos: .background))
			.receive(on: DispatchQueue.main)
			.sink { receiveCompltion in
				switch receiveCompltion {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
					completion(.failure(error))
				case .finished:
					ALog.info("Finished Dowloading image at \(urlString)")
				}
			} receiveValue: { value in
				completion(.success(value))
			}.store(in: &subscriptions)
		return publisher
	}
}
