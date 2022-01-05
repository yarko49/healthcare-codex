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

	func loadImage(url: URL) async throws -> UIImage {
		var request = Request(.GET, url: url)
		request = request.setHeaderValue(Request.ContentType.jpeg, forName: Request.Header.contentType)
		let urlRequest = try request.urlRequest()
		let result: (data: Data, response: URLResponse)

		if #available(iOS 15, *) {
			result = try await session.data(for: urlRequest, delegate: nil)
		} else {
			result = try await session.data(for: urlRequest)
		}
		let validData = try result.data.ws_validate(result.response).ws_validateNotEmptyData()
		guard let image = UIImage(data: validData) else {
			throw URLError(.cannotDecodeContentData)
		}
		return image
	}
}
