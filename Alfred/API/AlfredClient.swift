//
//  AlfredClient.swift
//  AlfredHealth
//
//  Created by Waqar Malik on 12/16/20.
//

import Combine
import Foundation

public final class AlfredClient {
	public var apiKey: String? {
		AppConfig.apiKey
	}

	public var authToken: String? {
		DataContext.shared.authToken
	}

	private let webService: WebService

	public init(session: URLSession = .shared) {
		self.webService = WebService(session: session)
	}

	@discardableResult
	public func getCarePlan(vectorClock: Bool = false, valueSpaceSample: Bool = false, completion: @escaping WebService.DecodableCompletion<CarePlanResponse>) -> URLSession.DataTaskPublisher? {
		let route = APIRouter.getCarePlan(vectorClock: vectorClock, valueSpaceSample: valueSpaceSample)
		return webService.request(route: route, completion: completion)
	}
}
