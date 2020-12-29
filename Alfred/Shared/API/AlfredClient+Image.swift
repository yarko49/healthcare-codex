//
//  AlfredClient+Image.swift
//  Alfred
//
//  Created by Waqar Malik on 12/29/20.
//

import UIKit

extension AlfredClient {
	func loadImage(urlString: String, completion: @escaping WebService.RequestCompletion<UIImage>) -> URLSession.ServicePublisher? {
		webService.loadImage(urlString: urlString, completion: completion)
	}
}
