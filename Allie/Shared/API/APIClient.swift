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
	func regiterProvider(identifier: String) -> Future<Bool, Never>
	func getCarePlan(vectorClock: Bool, valueSpaceSample: Bool, completion: @escaping WebService.DecodableCompletion<CarePlanResponse>) -> URLSession.ServicePublisher?
	func getCarePlan(vectorClock: Bool, valueSpaceSample: Bool) -> Future<CarePlanResponse, Error>
	func postCarePlan(carePlanResponse: CarePlanResponse, completion: @escaping WebService.DecodableCompletion<[String: Int]>) -> URLSession.ServicePublisher?
	func postBundle(bundle: ModelsR4.Bundle, completion: @escaping WebService.DecodableCompletion<ModelsR4.Bundle>) -> URLSession.ServicePublisher?
	func postObservation(observation: ModelsR4.Observation, completion: @escaping WebService.DecodableCompletion<ModelsR4.Observation>) -> URLSession.ServicePublisher?
	func postPatient(patient: AlliePatient) -> Future<CarePlanResponse, Error>
	func postPatient(patient: AlliePatient, completion: @escaping WebService.RequestCompletion<CarePlanResponse>) -> URLSession.ServicePublisher?
}

public final class APIClient: AllieAPI {
	static let client = APIClient()

	public var apiKey: String? {
		AppConfig.apiKey
	}

	public var authToken: String? {
		Keychain.authToken
	}

	let webService: WebService

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

	func regiterProvider(identifier: String) -> Future<Bool, Never> {
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
	public func getCarePlan(vectorClock: Bool = false, valueSpaceSample: Bool = false, completion: @escaping WebService.DecodableCompletion<CarePlanResponse>) -> URLSession.ServicePublisher? {
		let route = APIRouter.getCarePlan(vectorClock: vectorClock, valueSpaceSample: valueSpaceSample)
		return webService.request(route: route, completion: completion)
	}

	func getCarePlan(vectorClock: Bool = false, valueSpaceSample: Bool = false) -> Future<CarePlanResponse, Error> {
		Future { [weak self] promise in
			self?.getCarePlan(vectorClock: vectorClock, valueSpaceSample: valueSpaceSample, completion: { result in
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
	func postObservation(observation: ModelsR4.Observation, completion: @escaping WebService.DecodableCompletion<ModelsR4.Observation>) -> URLSession.ServicePublisher? {
		webService.request(route: APIRouter.postObservation(observation: observation), completion: completion)
	}

	@discardableResult
	func postBundle(bundle: ModelsR4.Bundle, completion: @escaping WebService.DecodableCompletion<ModelsR4.Bundle>) -> URLSession.ServicePublisher? {
		webService.request(route: APIRouter.postBundle(bundle: bundle), completion: completion)
	}

	func postPatient(patient: AlliePatient) -> Future<CarePlanResponse, Error> {
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
	func postPatient(patient: AlliePatient, completion: @escaping WebService.RequestCompletion<CarePlanResponse>) -> URLSession.ServicePublisher? {
		webService.request(route: .postPatient(patient: patient), completion: completion)
	}

	@discardableResult
	func getRawReaults(route: APIRouter, completion: @escaping WebService.RequestCompletion<[String: Any]>) -> URLSession.ServicePublisher? {
		webService.requestSerializable(route: route, completion: completion)
	}
}
