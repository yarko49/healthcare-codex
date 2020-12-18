//
//  AlfredClient.swift
//  AlfredHealth
//
//  Created by Waqar Malik on 12/16/20.
//

import AlfredCore
import Combine
import Foundation

protocol Routable {
	var request: Request { get }
}

public final class AlfredClient {
	public var baseURL: String {
		get {
			AlfredRouter.baseURL
		}
		set {
			AlfredRouter.baseURL = newValue
		}
	}

	public var apiKey: String? {
		get {
			AlfredRouter.apiKey
		}
		set {
			AlfredRouter.apiKey = newValue
		}
	}

	public var authToken: String? {
		get {
			AlfredRouter.authToken
		}
		set {
			AlfredRouter.authToken = newValue
		}
	}

	private let webService: WebService

	public init(session: URLSession = .shared) {
		self.webService = WebService(session: session)
	}

	@discardableResult
	public func getCarePlan(vectorClock: Bool = false, valueSpaceSample: Bool = false, completion: @escaping WebService.DecodableCompletion<CarePlanResponse>) -> URLSession.ServicePublisher? {
		let route = AlfredRouter.getCarePlan(vectorClock: vectorClock, valueSpaceSample: valueSpaceSample)
		return webService.request(request: route.request, completion: completion)
	}
}
