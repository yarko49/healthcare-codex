//
//  APIClient.swift
//  Allie
//
//  Created by Waqar Malik on 12/16/20.
//

import Combine
import Foundation
import KeychainAccess
import ModelsR4

protocol AllieAPI {
	func firebaseAuthenticationToken() -> Future<AuthenticationToken, Error>
	func registerOrganization(organization: CHOrganization) -> AnyPublisher<Bool, Never>
	func unregisterOrganization(organization: CHOrganization) -> AnyPublisher<Bool, Never>
	func getOrganizations() -> AnyPublisher<CHOrganizations, Never>
	func getConservations() -> AnyPublisher<CHConversations, Error>
	func getCarePlan(option: CarePlanResponseType) -> AnyPublisher<CHCarePlanResponse, Error>
	func post(carePlanResponse: CHCarePlanResponse) -> AnyPublisher<UInt64, Error>
	func post(bundle: ModelsR4.Bundle) -> AnyPublisher<ModelsR4.Bundle, Error>
	func post(patient: CHPatient) -> AnyPublisher<CHCarePlanResponse, Error>
	func getOutcomes(carePlanId: String, taskId: String, page: String) -> AnyPublisher<CHOutcomeResponse, Error>
	func post(outcomes: [CHOutcome]) -> AnyPublisher<CHCarePlanResponse, Error>
	func getFeatureContent(carePlanId: String, taskId: String, asset: String) -> AnyPublisher<SignedURLResponse, Error>
	func getData(url: URL) -> AnyPublisher<Data, Error>
}

public final class APIClient: AllieAPI {
	static let shared = APIClient()

	public var apiKey: String? {
		AppConfig.apiKey
	}

	let webService: WebService
	private var cancellables: Set<AnyCancellable> = []

	public init(session: URLSession = .shared) {
		session.configuration.httpMaximumConnectionsPerHost = 50
		session.configuration.timeoutIntervalForRequest = 120
		self.webService = WebService(session: session)
		webService.errorProcessor = { [weak self] request, error in
			self?.process(error: error, url: request?.url)
		}
		webService.responseHandler = { [weak self] response in
			try self?.process(response: response)
		}
	}

	private func process(response: HTTPURLResponse) throws {
		if response.statusCode == 401 {
			firebaseAuthenticationToken()
				.sink { [weak self] completion in
					if case .failure(let error) = completion {
						self?.process(error: error, url: response.url)
					}
				} receiveValue: { token in
					Keychain.authenticationToken = token
				}.store(in: &cancellables)
		}
	}

	private func process(error: Error, url: URL?) {
		let errorToSend = error as NSError
		var userInfo = errorToSend.userInfo
		userInfo["message"] = error.localizedDescription
		if let url = url {
			userInfo["url"] = url
		}
		let crashlyticsError = NSError(domain: errorToSend.domain, code: errorToSend.code, userInfo: userInfo)
		ALog.error(error: crashlyticsError)
	}

//	func postBundle(bundle: ModelsR4.Bundle) async -> ModelsR4.Bundle {}

	func registerOrganization(organization: CHOrganization) -> AnyPublisher<Bool, Never> {
		webService.simple(route: APIRouter.registerOrganization(organization))
			.catch { _ -> Just<Bool> in
				Just(false)
			}.eraseToAnyPublisher()
	}

	func unregisterOrganization(organization: CHOrganization) -> AnyPublisher<Bool, Never> {
		webService.simple(route: APIRouter.unregisterOrganization(organization))
			.catch { _ -> Just<Bool> in
				Just(false)
			}.eraseToAnyPublisher()
	}

	func getOrganizations() -> AnyPublisher<CHOrganizations, Never> {
		webService.request(route: .organizations)
			.catch { _ -> Just<CHOrganizations> in
				Just(CHOrganizations(available: [], registered: []))
			}.eraseToAnyPublisher()
	}

	func getConservations() -> AnyPublisher<CHConversations, Error> {
		webService.request(route: .conversations)
	}

	func getCarePlan(option: CarePlanResponseType = .carePlan) -> AnyPublisher<CHCarePlanResponse, Error> {
		let route = APIRouter.getCarePlan(option: option)
		return webService.request(route: route)
	}

	func post(carePlanResponse: CHCarePlanResponse) -> AnyPublisher<UInt64, Error> {
		webService.request(route: .postCarePlan(carePlanResponse: carePlanResponse))
	}

	func post(bundle: ModelsR4.Bundle) -> AnyPublisher<ModelsR4.Bundle, Error> {
		let route = APIRouter.postBundle(bundle: bundle)
		return webService.request(route: route)
	}

	func post(patient: CHPatient) -> AnyPublisher<CHCarePlanResponse, Error> {
		let route = APIRouter.postPatient(patient: patient)
		return webService.request(route: route)
	}

	func getRawReaults(route: APIRouter) -> AnyPublisher<Any, Error>? {
		webService.serializable(route: route)
	}

	func getOutcomes(carePlanId: String, taskId: String, page: String) -> AnyPublisher<CHOutcomeResponse, Error> {
		webService.request(route: .getOutcomes(carePlanId: carePlanId, taskId: taskId))
	}

	func post(outcomes: [CHOutcome]) -> AnyPublisher<CHCarePlanResponse, Error> {
		let route = APIRouter.postOutcomes(outcomes: outcomes)
		return webService.request(route: route)
	}

	func getFeatureContent(carePlanId: String, taskId: String, asset: String) -> AnyPublisher<SignedURLResponse, Error> {
		let route = APIRouter.getFeatureContent(carePlanId: carePlanId, taskId: taskId, asset: asset)
		return webService.request(route: route)
	}

	func getData(url: URL) -> AnyPublisher<Data, Error> {
		webService.data(url: url)
	}
}
