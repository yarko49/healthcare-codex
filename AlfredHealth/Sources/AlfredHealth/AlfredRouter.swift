//
//  AlfredRouter.swift
//  AlfredHealth
//
//  Created by Waqar Malik on 12/16/20.
//

import AlfredCore
import Foundation

enum AlfredRouter: Routable {
	static var baseURL = ""
	static var apiKey: String?
	static var authToken: String?

	case getCarePlan(vectorClock: Bool = false, valueSpaceSample: Bool = false)

	var method: Request.Method {
		switch self {
		case .getCarePlan:
			return .GET
		}
	}

	var path: String {
		switch self {
		case .getCarePlan:
			return "/carePlan"
		}
	}

	var headers: [String: String] {
		var headers: [String: String] = [:]
		headers[Request.Header.contentType] = Request.ContentType.json

		if let apiKey = AlfredRouter.apiKey {
			headers[Request.Header.xAPIKey] = apiKey
		}

		if let authToken = AlfredRouter.authToken {
			headers[Request.Header.userAuthorization] = "Bearer " + authToken
		}

		switch self {
		case .getCarePlan(let vectorClock, let valueSpaceSample):
			if vectorClock {
				headers[Request.Header.CarePlanVectorClockOnly] = "true"
			}

			if valueSpaceSample {
				headers[Request.Header.CarePlanPrefer] = "return=ValueSpaceSample"
			}
		}

		return headers
	}

	var parameters: [String: Any]? {
		nil
	}

	var queryParameters: [String: Any]? {
		nil
	}

	var request: Request {
		var request = Request(method, urlString: AlfredRouter.baseURL + path)
		request.setHeaders(headers)

		if let parameters = self.parameters {
			request.setParameters(parameters)
		}

		if let queryParameters = self.queryParameters {
			request.setQueryParameters(queryParameters)
		}

		return request
	}
}
