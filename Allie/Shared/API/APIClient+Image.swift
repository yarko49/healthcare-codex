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

	func loadImage(url: URL) -> AnyPublisher<UIImage, Error> {
		webService.loadImage(url: url)
	}
}
