//
//  URLComponents+Request.swift
//  Allie
//
//  Created by Waqar Malik on 12/16/20.
//

import Foundation

extension URLComponents {
	mutating func ws_appendQueryItems(_ newItems: [URLQueryItem]) {
		if let existingQueryItems = queryItems {
			queryItems = existingQueryItems + newItems
		} else {
			queryItems = newItems
		}
	}
}
