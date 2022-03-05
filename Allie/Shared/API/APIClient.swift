//
//  APIClient.swift
//  Allie
//
//  Created by Waqar Malik on 12/16/20.
//

import CareModel
import ClientAPI
import CodexFoundation
import CodexModel
import Combine
import KeychainAccess
import ModelsR4
import UIKit
import WebService

protocol AllieAPI {
	func firebaseAuthenticationToken() async throws -> AuthenticationToken
	func firebaseAuthenticationToken() -> Future<AuthenticationToken, Error>

	func registerOrganization(organization: CMOrganization) async -> Bool
	func registerOrganization(organization: CMOrganization) -> AnyPublisher<Bool, Never>

	func unregisterOrganization(organization: CMOrganization) async -> Bool
	func unregisterOrganization(organization: CMOrganization) -> AnyPublisher<Bool, Never>

	func getOrganizations() async throws -> CMOrganizations
	func getOrganizations() -> AnyPublisher<CMOrganizations, Error>

	func getConservationsTokens() async throws -> CMConversationsTokens
	func getConservationsTokens() -> AnyPublisher<CMConversationsTokens, Error>

	func postConservationsUsers(organizationId: String, users: [String]) async throws -> CMConversationsUsers
	func postConservationsUsers(organizationId: String, users: [String]) -> AnyPublisher<CMConversationsUsers, Error>

	func getCarePlan(option: CarePlanResponseType) async throws -> CHCarePlanResponse
	func getCarePlan(option: CarePlanResponseType) -> AnyPublisher<CHCarePlanResponse, Error>

	func post(carePlanResponse: CHCarePlanResponse) async throws -> CHCarePlanResponse
	func post(carePlanResponse: CHCarePlanResponse) -> AnyPublisher<CHCarePlanResponse, Error>

	func post(bundle: ModelsR4.Bundle) async throws -> ModelsR4.Bundle
	func post(bundle: ModelsR4.Bundle) -> AnyPublisher<ModelsR4.Bundle, Error>

	func post(patient: CHPatient) async throws -> CHCarePlanResponse
	func post(patient: CHPatient) -> AnyPublisher<CHCarePlanResponse, Error>

	func getOutcomes(carePlanId: String, taskId: String) async throws -> CHOutcomeResponse
	func getOutcomes(carePlanId: String, taskId: String) -> AnyPublisher<CHOutcomeResponse, Error>

	func getOutcomes(url: URL) async throws -> CHOutcomeResponse
	func getOutcomes(url: URL) -> AnyPublisher<CHOutcomeResponse, Error>

	func post(outcomes: [CHOutcome]) async throws -> CHCarePlanResponse
	func post(outcomes: [CHOutcome]) -> AnyPublisher<CHCarePlanResponse, Error>

	func getFeatureContent(carePlanId: String, taskId: String, asset: String) async throws -> CMSignedURLResponse
	func getFeatureContent(carePlanId: String, taskId: String, asset: String) -> AnyPublisher<CMSignedURLResponse, Error>

	func getData(url: URL) async throws -> Data
	func getData(url: URL) -> AnyPublisher<Data, Error>

	func uploadRemoteNotification(token: String) async throws -> Bool
	func uploadRemoteNotification(token: String) -> AnyPublisher<Bool, Error>

	func getCloudDevices() async throws -> CMCloudDevices
	func getCloudDevices() -> AnyPublisher<CMCloudDevices, Error>

	func postIntegrate(cloudDevice: CMCloudDevice) async throws -> Bool
	func postIntegrate(cloudDevice: CMCloudDevice) -> AnyPublisher<Bool, Error>

	func deleteIntegration(cloudDevice: CMCloudDevice) async throws -> Bool
	func deleteIntegration(cloudDevice: CMCloudDevice) -> AnyPublisher<Bool, Error>

	func loadImage(urlString: String) async throws -> UIImage
	func loadImage(urlString: String) -> AnyPublisher<UIImage, Error>

	func loadImage(url: URL) async throws -> UIImage
	func loadImage(url: URL) -> AnyPublisher<UIImage, Error>
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

	func registerOrganization(organization: CMOrganization) async -> Bool {
		(try? await webService.simple(route: APIRouter.registerOrganization(organization))) ?? false
	}

	func registerOrganization(organization: CMOrganization) -> AnyPublisher<Bool, Never> {
		webService.simple(route: APIRouter.registerOrganization(organization))
			.catch { _ -> Just<Bool> in
				Just(false)
			}.eraseToAnyPublisher()
	}

	func unregisterOrganization(organization: CMOrganization) async -> Bool {
		(try? await webService.simple(route: APIRouter.unregisterOrganization(organization))) ?? false
	}

	func unregisterOrganization(organization: CMOrganization) -> AnyPublisher<Bool, Never> {
		webService.simple(route: APIRouter.unregisterOrganization(organization))
			.catch { _ -> Just<Bool> in
				Just(false)
			}.eraseToAnyPublisher()
	}

	func getOrganizations() async throws -> CMOrganizations {
		try await webService.decodable(route: .organizations)
	}

	func getOrganizations() -> AnyPublisher<CMOrganizations, Error> {
		webService.decodable(route: .organizations)
	}

	func getConservationsTokens() async throws -> CMConversationsTokens {
		try await webService.decodable(route: .conversationsTokens)
	}

	func getConservationsTokens() -> AnyPublisher<CMConversationsTokens, Error> {
		webService.decodable(route: .conversationsTokens)
	}

	func postConservationsUsers(organizationId: String, users: [String]) async throws -> CMConversationsUsers {
		try await webService.decodable(route: .postConversationsUsers(organizationId, users))
	}

	func postConservationsUsers(organizationId: String, users: [String]) -> AnyPublisher<CMConversationsUsers, Error> {
		webService.decodable(route: .postConversationsUsers(organizationId, users))
	}

	func getCarePlan(option: CarePlanResponseType) async throws -> CHCarePlanResponse {
		let route = APIRouter.getCarePlan(option: option)
		return try await webService.decodable(route: route)
	}

	func getCarePlan(option: CarePlanResponseType = .carePlan) -> AnyPublisher<CHCarePlanResponse, Error> {
		let route = APIRouter.getCarePlan(option: option)
		return webService.decodable(route: route)
	}

	func post(carePlanResponse: CHCarePlanResponse) async throws -> CHCarePlanResponse {
		try await webService.decodable(route: .postCarePlan(carePlanResponse: carePlanResponse))
	}

	func post(carePlanResponse: CHCarePlanResponse) -> AnyPublisher<CHCarePlanResponse, Error> {
		webService.decodable(route: .postCarePlan(carePlanResponse: carePlanResponse))
	}

	func post(bundle: ModelsR4.Bundle) async throws -> ModelsR4.Bundle {
		try await webService.decodable(route: APIRouter.postBundle(bundle: bundle))
	}

	func post(bundle: ModelsR4.Bundle) -> AnyPublisher<ModelsR4.Bundle, Error> {
		let route = APIRouter.postBundle(bundle: bundle)
		return webService.decodable(route: route)
	}

	func post(patient: CHPatient) async throws -> CHCarePlanResponse {
		try await webService.decodable(route: APIRouter.postPatient(patient: patient))
	}

	func post(patient: CHPatient) -> AnyPublisher<CHCarePlanResponse, Error> {
		let route = APIRouter.postPatient(patient: patient)
		return webService.decodable(route: route)
	}

	func getOutcomes(carePlanId: String, taskId: String) async throws -> CHOutcomeResponse {
		try await webService.decodable(route: .getOutcomes(carePlanId: carePlanId, taskId: taskId))
	}

	func getOutcomes(carePlanId: String, taskId: String) -> AnyPublisher<CHOutcomeResponse, Error> {
		webService.decodable(route: .getOutcomes(carePlanId: carePlanId, taskId: taskId))
	}

	func getOutcomes(url: URL) async throws -> CHOutcomeResponse {
		try await webService.decodable(request: Request(.GET, url: url))
	}

	func getOutcomes(url: URL) -> AnyPublisher<CHOutcomeResponse, Error> {
		let request = Request(.GET, url: url)
		return webService.decodable(request: request)
	}

	func post(outcomes: [CHOutcome]) async throws -> CHCarePlanResponse {
		let route = APIRouter.postOutcomes(outcomes: outcomes)
		return try await webService.decodable(route: route)
	}

	func post(outcomes: [CHOutcome]) -> AnyPublisher<CHCarePlanResponse, Error> {
		let route = APIRouter.postOutcomes(outcomes: outcomes)
		return webService.decodable(route: route)
	}

	func getFeatureContent(carePlanId: String, taskId: String, asset: String) async throws -> CMSignedURLResponse {
		let route = APIRouter.getFeatureContent(carePlanId: carePlanId, taskId: taskId, asset: asset)
		return try await webService.decodable(route: route)
	}

	func getFeatureContent(carePlanId: String, taskId: String, asset: String) -> AnyPublisher<CMSignedURLResponse, Error> {
		let route = APIRouter.getFeatureContent(carePlanId: carePlanId, taskId: taskId, asset: asset)
		return webService.decodable(route: route)
	}

	func getData(url: URL) async throws -> Data {
		try await webService.data(request: Request(.GET, url: url))
	}

	func getData(url: URL) -> AnyPublisher<Data, Error> {
		webService.data(request: Request(.GET, url: url))
	}

	func uploadRemoteNotification(token: String) async throws -> Bool {
		try await webService.simple(route: .postNotificationToken(token))
	}

	func uploadRemoteNotification(token: String) -> AnyPublisher<Bool, Error> {
		webService.simple(route: .postNotificationToken(token))
	}

	func getCloudDevices() async throws -> CMCloudDevices {
		try await webService.decodable(route: .integrations)
	}

	func getCloudDevices() -> AnyPublisher<CMCloudDevices, Error> {
		webService.decodable(route: .integrations)
	}

	func postIntegrate(cloudDevice: CMCloudDevice) async throws -> Bool {
		try await webService.simple(route: .postIntegration(cloudDevice))
	}

	func postIntegrate(cloudDevice: CMCloudDevice) -> AnyPublisher<Bool, Error> {
		webService.simple(route: .postIntegration(cloudDevice))
	}

	func deleteIntegration(cloudDevice: CMCloudDevice) async throws -> Bool {
		try await webService.simple(route: .deleteIntegration(cloudDevice))
	}

	func deleteIntegration(cloudDevice: CMCloudDevice) -> AnyPublisher<Bool, Error> {
		webService.simple(route: .deleteIntegration(cloudDevice))
	}
}
