//
//  APIClient.swift
//  Allie
//
//  Created by Waqar Malik on 12/16/20.
//

import Combine
import KeychainAccess
import ModelsR4
import UIKit
import WebService

protocol AllieAPI {
	func firebaseAuthenticationToken() -> Future<AuthenticationToken, Error>
	func registerOrganization(organization: CHOrganization) -> AnyPublisher<Bool, Never>
	func unregisterOrganization(organization: CHOrganization) -> AnyPublisher<Bool, Never>
	func getOrganizations() -> AnyPublisher<CHOrganizations, Never>
	func getConservationsTokens() -> AnyPublisher<CHConversationsTokens, Error>
	func postConservationsUsers(organizationId: String, users: [String]) -> AnyPublisher<CHConversationsUsers, Error>

	func getCarePlan(option: CarePlanResponseType) async throws -> CHCarePlanResponse
	func getCarePlan(option: CarePlanResponseType) -> AnyPublisher<CHCarePlanResponse, Error>

	func post(carePlanResponse: CHCarePlanResponse) -> AnyPublisher<UInt64, Error>
	func post(bundle: ModelsR4.Bundle) -> AnyPublisher<ModelsR4.Bundle, Error>
	func post(patient: CHPatient) -> AnyPublisher<CHCarePlanResponse, Error>
	func getOutcomes(carePlanId: String, taskId: String) -> AnyPublisher<CHOutcomeResponse, Error>
	func getOutcomes(url: URL) -> AnyPublisher<CHOutcomeResponse, Error>
	func post(outcomes: [CHOutcome]) -> AnyPublisher<CHCarePlanResponse, Error>

	func getFeatureContent(carePlanId: String, taskId: String, asset: String) -> AnyPublisher<SignedURLResponse, Error>
	func getFeatureContent(carePlanId: String, taskId: String, asset: String) async throws -> SignedURLResponse

	func getData(url: URL) -> AnyPublisher<Data, Error>
	func getData(url: URL) async throws -> Data

	func uploadRemoteNotification(token: String) -> AnyPublisher<Bool, Error>
	func getCloudDevices() -> AnyPublisher<CHCloudDevices, Error>
	func postIntegrate(cloudDevice: CHCloudDevice) -> AnyPublisher<Bool, Error>
	func deleteIntegration(cloudDevice: CHCloudDevice) -> AnyPublisher<Bool, Error>

	func loadImage(urlString: String) -> AnyPublisher<UIImage, Error>
	func loadImage(urlString: String) async throws -> UIImage

	func loadImage(url: URL) -> AnyPublisher<UIImage, Error>
	func loadImage(url: URL) async throws -> UIImage
}

public final class APIClient: AllieAPI {
	public var apiKey: String? {
		AppConfig.apiKey
	}

	@Injected(\.keychain) var keychain: Keychain
	let webService: WebService
	private var cancellables: Set<AnyCancellable> = []

	public init(session: URLSession = .shared) {
		session.configuration.httpMaximumConnectionsPerHost = 50
		session.configuration.timeoutIntervalForRequest = 120
		self.webService = WebService(baseURLString: APIRouter.baseURLPath, session: session)
//		webService.errorProcessor = { [weak self] request, error in
//			self?.process(error: error, url: request?.url)
//		}
//		webService.responseHandler = { [weak self] response in
//			try self?.process(response: response)
//		}
	}

	private func process(response: HTTPURLResponse) throws {
		if response.statusCode == 401 {
			firebaseAuthenticationToken()
				.sink { [weak self] completion in
					if case .failure(let error) = completion {
						self?.process(error: error, url: response.url)
					}
				} receiveValue: { token in
					DispatchQueue.main.async { [weak self] in
						self?.keychain.authenticationToken = token
					}
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
		webService.decodable(route: .organizations)
			.catch { _ -> Just<CHOrganizations> in
				Just(CHOrganizations(available: [], registered: []))
			}.eraseToAnyPublisher()
	}

	func getConservationsTokens() -> AnyPublisher<CHConversationsTokens, Error> {
		webService.decodable(route: .conversationsTokens)
	}

	func postConservationsUsers(organizationId: String, users: [String]) -> AnyPublisher<CHConversationsUsers, Error> {
		webService.decodable(route: .postConversationsUsers(organizationId, users))
	}

	func getCarePlan(option: CarePlanResponseType) async throws -> CHCarePlanResponse {
		let route = APIRouter.getCarePlan(option: option)
		let request = try route.request()
		return try await webService.decodable(request: request)
	}

	func getCarePlan(option: CarePlanResponseType = .carePlan) -> AnyPublisher<CHCarePlanResponse, Error> {
		let route = APIRouter.getCarePlan(option: option)
		return webService.decodable(route: route)
	}

	func post(carePlanResponse: CHCarePlanResponse) -> AnyPublisher<UInt64, Error> {
		webService.decodable(route: .postCarePlan(carePlanResponse: carePlanResponse))
	}

	func post(bundle: ModelsR4.Bundle) -> AnyPublisher<ModelsR4.Bundle, Error> {
		let route = APIRouter.postBundle(bundle: bundle)
		return webService.decodable(route: route)
	}

	func post(patient: CHPatient) -> AnyPublisher<CHCarePlanResponse, Error> {
		let route = APIRouter.postPatient(patient: patient)
		return webService.decodable(route: route)
	}

	func getRawReaults(route: APIRouter) -> AnyPublisher<Any, Error>? {
		webService.serializable(route: route)
	}

	func getOutcomes(carePlanId: String, taskId: String) -> AnyPublisher<CHOutcomeResponse, Error> {
		webService.decodable(route: .getOutcomes(carePlanId: carePlanId, taskId: taskId))
	}

	func getOutcomes(url: URL) -> AnyPublisher<CHOutcomeResponse, Error> {
		let request = Request(.GET, url: url)
		return webService.decodable(request: request)
	}

	func post(outcomes: [CHOutcome]) -> AnyPublisher<CHCarePlanResponse, Error> {
		let route = APIRouter.postOutcomes(outcomes: outcomes)
		return webService.decodable(route: route)
	}

	func getFeatureContent(carePlanId: String, taskId: String, asset: String) -> AnyPublisher<SignedURLResponse, Error> {
		let route = APIRouter.getFeatureContent(carePlanId: carePlanId, taskId: taskId, asset: asset)
		return webService.decodable(route: route)
	}

	func getFeatureContent(carePlanId: String, taskId: String, asset: String) async throws -> SignedURLResponse {
		let route = APIRouter.getFeatureContent(carePlanId: carePlanId, taskId: taskId, asset: asset)
		let request = try route.request()
		return try await webService.decodable(request: request)
	}

	func getData(url: URL) -> AnyPublisher<Data, Error> {
		webService.data(request: Request(.GET, url: url))
	}

	func getData(url: URL) async throws -> Data {
		try await webService.data(request: Request(.GET, url: url))
	}

	func uploadRemoteNotification(token: String) -> AnyPublisher<Bool, Error> {
		webService.simple(route: .postNotificationToken(token))
	}

	func getCloudDevices() -> AnyPublisher<CHCloudDevices, Error> {
		webService.decodable(route: .integrations)
	}

	func postIntegrate(cloudDevice: CHCloudDevice) -> AnyPublisher<Bool, Error> {
		webService.simple(route: .postIntegration(cloudDevice))
	}

	func deleteIntegration(cloudDevice: CHCloudDevice) -> AnyPublisher<Bool, Error> {
		webService.simple(route: .deleteIntegration(cloudDevice))
	}
}
