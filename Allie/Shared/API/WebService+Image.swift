//
//  WebService+Image.swift
//  Allie
//
//  Created by Waqar Malik on 12/13/20.
//

import Combine
import UIKit
import WebService

public extension WebService {
	func loadImage(urlString: String) -> AnyPublisher<UIImage, Error> {
		guard let url = URL(string: urlString) else {
			return Fail(error: URLError(.badURL))
				.eraseToAnyPublisher()
		}

		return loadImage(url: url)
	}

	func loadImage(url: URL) -> AnyPublisher<UIImage, Error> {
		session.servicePublisher(for: url)
			.setHeaderValue(Request.ContentType.jpeg, forName: Request.Header.contentType)
			.tryMap { result -> Data in
				try result.data.ws_validate(result.response).ws_validateNotEmptyData()
			}.tryMap { data -> UIImage in
				guard let image = UIImage(data: data) else {
					throw URLError(.cannotDecodeContentData)
				}
				return image
			}.subscribe(on: DispatchQueue.global(qos: .background))
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}
}
