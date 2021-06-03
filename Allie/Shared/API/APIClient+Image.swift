//
//  APIClient+Image.swift
//  Allie
//
//  Created by Waqar Malik on 12/29/20.
//

import UIKit

extension APIClient {
	@discardableResult
	func loadImage(urlString: String, completion: @escaping WebService.RequestCompletion<UIImage>) -> URLSession.ServicePublisher? {
		webService.loadImage(urlString: urlString, completion: completion)
	}

	@discardableResult
	func loadImage(url: URL, completion: @escaping WebService.RequestCompletion<UIImage>) -> URLSession.ServicePublisher? {
		webService.loadImage(url: url, completion: completion)
	}
}
