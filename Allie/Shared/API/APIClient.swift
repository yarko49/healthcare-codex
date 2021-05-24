//
//  APIClient.swift
//  Allie
//
//  Created by Waqar Malik on 12/16/20.
//

import Combine
import Foundation
import ModelsR4

protocol AllieAPI {
	func registerProvider(identifier: String) -> Future<Bool, Never>
	func getCarePlan(option: CarePlanResponseType, completion: @escaping WebService.DecodableCompletion<CarePlanResponse>) -> URLSession.ServicePublisher?
	func getCarePlan(option: CarePlanResponseType) -> Future<CarePlanResponse, Error>
	func postCarePlan(carePlanResponse: CarePlanResponse, completion: @escaping WebService.DecodableCompletion<[String: Int]>) -> URLSession.ServicePublisher?
	func post(bundle: ModelsR4.Bundle, completion: @escaping WebService.DecodableCompletion<ModelsR4.Bundle>) -> URLSession.ServicePublisher?
	func post(bundle: ModelsR4.Bundle) -> Future<ModelsR4.Bundle, Error>
	func post(observation: ModelsR4.Observation, completion: @escaping WebService.DecodableCompletion<ModelsR4.Observation>) -> URLSession.ServicePublisher?
	func post(patient: AlliePatient) -> Future<CarePlanResponse, Error>
	func post(patient: AlliePatient, completion: @escaping WebService.RequestCompletion<CarePlanResponse>) -> URLSession.ServicePublisher?
	func getOutcomes() -> Future<CarePlanResponse, Error>
	func post(outcomes: [Outcome]) -> Future<CarePlanResponse, Error>
}

public final class APIClient: AllieAPI {
	static let shared = APIClient()

	public var apiKey: String? {
		AppConfig.apiKey
	}

	let webService: WebService

	private(set) lazy var backgroundSession: URLSession = {
		let session = URLSession(configuration: APIClient.backgroundSessionConfiguration)
		return session
	}()

	static var sessionIdentifier: String {
		let bundleIdentifier = Bundle.main.bundleIdentifier!
		return bundleIdentifier + ".networking"
	}

	static var backgroundSessionConfiguration: URLSessionConfiguration {
		let config = URLSessionConfiguration.background(withIdentifier: sessionIdentifier)
		config.isDiscretionary = true
		config.sessionSendsLaunchEvents = true
		config.httpMaximumConnectionsPerHost = 1
		return config
	}

	public init(session: URLSession = .shared) {
		session.configuration.httpMaximumConnectionsPerHost = 50
		session.configuration.timeoutIntervalForRequest = 120
		self.webService = WebService(session: session)
		webService.errorProcessor = { request, error in
			let errorToSend = error as NSError
			var userInfo = errorToSend.userInfo
			userInfo["message"] = error.localizedDescription
			if let url = request?.url {
				userInfo["url"] = url
			}
			let crashlyticsError = NSError(domain: errorToSend.domain, code: errorToSend.code, userInfo: userInfo)
			ALog.error(error: crashlyticsError)
		}
	}

//	func postBundle(bundle: ModelsR4.Bundle) async -> ModelsR4.Bundle {}

	func registerProvider(identifier: String) -> Future<Bool, Never> {
		Future { [weak self] promise in
			_ = self?.webService.requestSimple(route: APIRouter.registerProvider(HealthCareProvider(id: identifier)), completion: { result in
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

	@discardableResult
	public func getCarePlan(option: CarePlanResponseType = .carePlan, completion: @escaping WebService.DecodableCompletion<CarePlanResponse>) -> URLSession.ServicePublisher? {
		let route = APIRouter.getCarePlan(option: option)
		return webService.request(route: route, completion: completion)
	}

	func getCarePlan(option: CarePlanResponseType = .carePlan) -> Future<CarePlanResponse, Error> {
		Future { [weak self] promise in
			self?.getCarePlan(option: option, completion: { result in
				switch result {
				case .failure(let error):
					promise(.failure(error))
				case .success(let plan):
					promise(.success(plan))
				}
			})
		}
	}

	@discardableResult
	func postCarePlan(carePlanResponse: CarePlanResponse, completion: @escaping WebService.DecodableCompletion<[String: Int]>) -> URLSession.ServicePublisher? {
		let route = APIRouter.postCarePlan(carePlanResponse: carePlanResponse)
		return webService.request(route: route, completion: completion)
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

	func post(patient: AlliePatient) -> Future<CarePlanResponse, Error> {
		Future { [weak self] promise in
			let route = APIRouter.postPatient(patient: patient)
			_ = self?.webService.request(route: route) { (result: Result<CarePlanResponse, Error>) in
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
	func post(patient: AlliePatient, completion: @escaping WebService.RequestCompletion<CarePlanResponse>) -> URLSession.ServicePublisher? {
		webService.request(route: .postPatient(patient: patient), completion: completion)
	}

	@discardableResult
	func getRawReaults(route: APIRouter, completion: @escaping WebService.RequestCompletion<[String: Any]>) -> URLSession.ServicePublisher? {
		webService.requestSerializable(route: route, completion: completion)
	}

	func getOutcomes() -> Future<CarePlanResponse, Error> {
		Future { [weak self] promise in
			let route = APIRouter.getCarePlan(option: .outcomes)
			_ = self?.webService.request(route: route, completion: { (result: Result<CarePlanResponse, Error>) in
				switch result {
				case .failure(let error):
					promise(.failure(error))
				case .success(let carePlanResponse):
					promise(.success(carePlanResponse))
				}
			})
		}
	}

	func post(outcomes: [Outcome]) -> Future<CarePlanResponse, Error> {
		Future { [weak self] promise in
			let route = APIRouter.postOutcomes(outcomes: outcomes)
			_ = self?.webService.request(route: route) { (result: Result<CarePlanResponse, Error>) in
				switch result {
				case .failure(let error):
					promise(.failure(error))
				case .success(let response):
					promise(.success(response))
				}
			}
		}
	}
}
