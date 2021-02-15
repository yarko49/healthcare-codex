//
//  Data+Validation.swift
//  Allie
//
//  Created by Waqar Malik on 11/23/20.
//

import Foundation

extension Data {
	func ws_validate() throws -> Self {
		guard !isEmpty else {
			throw URLError(.zeroByteResource)
		}
		return self
	}

	func ws_validate(_ response: URLResponse, acceptableStatusCodes: Range<Int> = 200 ..< 300) throws -> Self {
		guard let httpResponse = response as? HTTPURLResponse else {
			throw URLError(.badServerResponse)
		}

		guard acceptableStatusCodes.contains(httpResponse.statusCode) else {
			let errorCode = URLError.Code(rawValue: httpResponse.statusCode)
			throw URLError(errorCode)
		}

		return self
	}

	func ws_validate(_ response: URLResponse, acceptableContentTypes: [String]) throws -> Self {
		guard let httpResponse = response as? HTTPURLResponse else {
			throw URLError(.badServerResponse)
		}

		guard let contentType = httpResponse.allHeaderFields[Request.Header.contentType] as? String, acceptableContentTypes.contains(contentType) else {
			throw URLError(.dataNotAllowed)
		}

		return self
	}

	static func ws_validate(_ data: Data, _ response: URLResponse) throws -> Self {
		try data.ws_validate(response).ws_validate()
	}
}
