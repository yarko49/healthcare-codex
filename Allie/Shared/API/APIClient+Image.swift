//
//  APIClient+Image.swift
//  Allie
//
//  Created by Waqar Malik on 12/29/20.
//

import Combine
import UIKit

extension APIClient {
	func loadImage(urlString: String) -> AnyPublisher<UIImage, Error> {
		webService.loadImage(urlString: urlString)
	}

	func loadImage(urlString: String) async throws -> UIImage {
		guard let url = URL(string: urlString) else {
			throw URLError(.badURL)
		}
		return try await loadImage(url: url)
	}

	func loadImage(url: URL) -> AnyPublisher<UIImage, Error> {
		webService.loadImage(url: url)
	}

	func loadImage(url: URL) async throws -> UIImage {
		try await webService.loadImage(url: url)
	}
}
