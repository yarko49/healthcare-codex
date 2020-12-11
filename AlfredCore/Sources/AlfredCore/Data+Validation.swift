//
//  Data+Validation.swift
//  AlfredCore
//
//  Created by Waqar Malik on 11/23/20.
//

import Foundation

extension Data {
	func cws_validate() throws -> Self {
		guard !isEmpty else {
			throw URLError(.zeroByteResource)
		}
		return self
	}

	func cws_validate(_ response: URLResponse, acceptableStatusCodes: Range<Int> = 200 ..< 300) throws -> Self {
		guard let httpResponse = response as? HTTPURLResponse else {
			throw URLError(.badServerResponse)
		}

		guard acceptableStatusCodes.contains(httpResponse.statusCode) else {
			let errorCode = URLError.Code(rawValue: httpResponse.statusCode)
			throw URLError(errorCode)
		}

		return self
	}

	func cws_validate(_ response: URLResponse, acceptableContentTypes: [String]) throws -> Self {
		guard let httpResponse = response as? HTTPURLResponse else {
			throw URLError(.badServerResponse)
		}

		guard let contentType = httpResponse.allHeaderFields["Content-Type"] as? String, acceptableContentTypes.contains(contentType) else {
			throw URLError(.cannotDecodeContentData)
		}

		return self
	}

	static func cws_validate(_ data: Data, _ response: URLResponse) throws -> Self {
		try data.cws_validate(response, acceptableStatusCodes: 200 ..< 300).cws_validate()
	}
}
