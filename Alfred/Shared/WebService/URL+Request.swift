//
//  URL+Request.swift
//  Alfred
//
//  Created by Waqar Malik on 12/16/20.
//

import Foundation

extension URL {
	func ws_URLByAppendingQueryItems(_ newItems: [URLQueryItem]) -> Self? {
		var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
		components?.ws_appendQueryItems(newItems)
		return components?.url
	}
}
