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
	func registerOrganization(organization: CHOrganization) -> Future<Bool, Never>
	func getCarePlan(option: CarePlanResponseType) -> Future<CHCarePlanResponse, Error>
	func post(carePlanResponse: CHCarePlanResponse) -> Future<UInt64, Error>
	func post(bundle: ModelsR4.Bundle, completion: @escaping WebService.DecodableCompletion<ModelsR4.Bundle>) -> URLSession.ServicePublisher?
	func post(bundle: ModelsR4.Bundle) -> Future<ModelsR4.Bundle, Error>
	func post(observation: ModelsR4.Observation, completion: @escaping WebService.DecodableCompletion<ModelsR4.Observation>) -> URLSession.ServicePublisher?
	func post(patient: CHPatient) -> Future<CHCarePlanResponse, Error>
	func post(patient: CHPatient, completion: @escaping WebService.RequestCompletion<CHCarePlanResponse>) -> URLSession.ServicePublisher?
	func getOutcomes() -> Future<CHCarePlanResponse, Error>
	func post(outcomes: [CHOutcome]) -> Future<CHCarePlanResponse, Error>
	func getFeatureContent(carePlanId: String, taskId: String, asset: String) -> Future<SignedURLResponse, Error>
	func getData(url: URL) -> Future<Data, Error>
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

	func registerOrganization(organization: CHOrganization) -> Future<Bool, Never> {
		Future { [weak self] promise in
			_ = self?.webService.requestSimple(route: APIRouter.registerOrganization(organization), completion: { result in
				switch result {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
					promise(.success(false))
				case .success:
					promise(.success(true))
				}
			})
		}
	}

	func getCarePlan(option: CarePlanResponseType = .carePlan) -> Future<CHCarePlanResponse, Error> {
		Future { [weak self] promise in
			let route = APIRouter.getCarePlan(option: option)
			_ = self?.webService.request(route: route, completion: { (result: Result<CHCarePlanResponse, Error>) in
				switch result {
				case .failure(let error):
					promise(.failure(error))
				case .success(let plan):
					promise(.success(plan))
				}
			})
		}
	}

	func post(carePlanResponse: CHCarePlanResponse) -> Future<UInt64, Error> {
		Future { [weak self] promise in
			_ = self?.webService.request(route: .postCarePlan(carePlanResponse: carePlanResponse)) { (result: Result<UInt64, Error>) in
				switch result {
				case .failure(let error):
					promise(.failure(error))
				case .success(let clock):
					promise(.success(clock))
				}
			}
		}
	}

	@discardableResult
	func post(observation: ModelsR4.Observation, completion: @escaping WebService.DecodableCompletion<ModelsR4.Observation>) -> URLSession.ServicePublisher? {
		webService.request(route: APIRouter.postObservation(observation: observation), completion: completion)
	}

	@discardableResult
	func post(bundle: ModelsR4.Bundle, completion: @escaping WebService.DecodableCompletion<ModelsR4.Bundle>) -> URLSession.ServicePublisher? {
		webService.request(route: APIRouter.postBundle(bundle: bundle), completion: completion)
	}

	func post(bundle: ModelsR4.Bundle) -> Future<ModelsR4.Bundle, Error> {
		Future { [weak self] promise in
			let route = APIRouter.postBundle(bundle: bundle)
			_ = self?.webService.request(route: route) { (result: Result<ModelsR4.Bundle, Error>) in
				switch result {
				case .failure(let error):
					promise(.failure(error))
				case .success(let response):
					promise(.success(response))
				}
			}
		}
	}

	func post(patient: CHPatient) -> Future<CHCarePlanResponse, Error> {
		Future { [weak self] promise in
			let route = APIRouter.postPatient(patient: patient)
			_ = self?.webService.request(route: route) { (result: Result<CHCarePlanResponse, Error>) in
				switch result {
				case .failure(let error):
					promise(.failure(error))
				case .success(let response):
					promise(.success(response))
				}
			}
		}
	}

	@discardableResult
	func post(patient: CHPatient, completion: @escaping WebService.RequestCompletion<CHCarePlanResponse>) -> URLSession.ServicePublisher? {
		webService.request(route: .postPatient(patient: patient), completion: completion)
	}

	@discardableResult
	func getRawReaults(route: APIRouter, completion: @escaping WebService.RequestCompletion<[String: Any]>) -> URLSession.ServicePublisher? {
		webService.requestSerializable(route: route, completion: completion)
	}

	func getOutcomes() -> Future<CHCarePlanResponse, Error> {
		Future { [weak self] promise in
			let route = APIRouter.getCarePlan(option: .outcomes)
			_ = self?.webService.request(route: route, completion: { (result: Result<CHCarePlanResponse, Error>) in
				switch result {
				case .failure(let error):
					promise(.failure(error))
				case .success(let carePlanResponse):
					promise(.success(carePlanResponse))
				}
			})
		}
	}

	func post(outcomes: [CHOutcome]) -> Future<CHCarePlanResponse, Error> {
		Future { [weak self] promise in
			let route = APIRouter.postOutcomes(outcomes: outcomes)
			_ = self?.webService.request(route: route) { (result: Result<CHCarePlanResponse, Error>) in
				switch result {
				case .failure(let error):
					promise(.failure(error))
				case .success(let response):
					promise(.success(response))
				}
			}
		}
	}

	func getFeatureContent(carePlanId: String, taskId: String, asset: String) -> Future<SignedURLResponse, Error> {
		Future { [weak self] promise in
			let route = APIRouter.getFeatureContent(carePlanId: carePlanId, taskId: taskId, asset: asset)
			_ = self?.webService.request(route: route, completion: { (result: Result<SignedURLResponse, Error>) in
				switch result {
				case .failure(let error):
					promise(.failure(error))
				case .success(let response):
					promise(.success(response))
				}
			})
		}
	}

	func getData(url: URL) -> Future<Data, Error> {
		webService.requestData(url: url)
	}
}
