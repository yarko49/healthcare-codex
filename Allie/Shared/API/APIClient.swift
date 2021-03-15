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
	func registerProvider(identifier: String, completion: @escaping WebService.RequestCompletion<Bool>) -> URLSession.ServicePublisher?
	func getCarePlan(vectorClock: Bool, valueSpaceSample: Bool, completion: @escaping WebService.DecodableCompletion<CarePlanResponse>) -> URLSession.ServicePublisher?
	func postCarePlan(carePlanResponse: CarePlanResponse, completion: @escaping WebService.DecodableCompletion<[String: Int]>) -> URLSession.ServicePublisher?
	func postBundle(bundle: ModelsR4.Bundle, completion: @escaping WebService.DecodableCompletion<ModelsR4.Bundle>) -> URLSession.ServicePublisher?
	func postObservation(observation: ModelsR4.Observation, completion: @escaping WebService.DecodableCompletion<ModelsR4.Observation>) -> URLSession.ServicePublisher?
	func postPatient(patient: AlliePatient, completion: @escaping WebService.RequestCompletion<[String: Any]>) -> URLSession.ServicePublisher?

	// Death Row
	func getQuestionnaire(completion: @escaping WebService.DecodableCompletion<Questionnaire>) -> URLSession.ServicePublisher?
	func postQuestionnaireResponse(questionnaireResponse: QuestionnaireResponse, completion: @escaping WebService.DecodableCompletion<SubmittedQuestionnaire>) -> URLSession.ServicePublisher?
	func getProfile(completion: @escaping WebService.DecodableCompletion<Profile>) -> URLSession.ServicePublisher?
	func postProfile(profile: Profile, completion: @escaping WebService.RequestCompletion<Bool>) -> URLSession.ServicePublisher?
	func patchPatient(patient: [UpdatePatientModel], completion: @escaping WebService.DecodableCompletion<CodexResource>) -> URLSession.ServicePublisher?
	func getCardList(completion: @escaping WebService.DecodableCompletion<CardList>) -> URLSession.ServicePublisher?
	func postObservationSearch(search: SearchParameter, completion: @escaping WebService.DecodableCompletion<CodexBundle>) -> URLSession.ServicePublisher?
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

	@discardableResult
	func registerProvider(identifier: String, completion: @escaping WebService.RequestCompletion<Bool>) -> URLSession.ServicePublisher? {
		webService.request(route: APIRouter.registerProvider(HealthCareProvider(id: identifier)), completion: completion)
	}

	@discardableResult
	public func getCarePlan(vectorClock: Bool = false, valueSpaceSample: Bool = false, completion: @escaping WebService.DecodableCompletion<CarePlanResponse>) -> URLSession.ServicePublisher? {
		let route = APIRouter.getCarePlan(vectorClock: vectorClock, valueSpaceSample: valueSpaceSample)
		return webService.request(route: route, completion: completion)
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
	func postPatient(patient: AlliePatient, completion: @escaping WebService.RequestCompletion<[String: Any]>) -> URLSession.ServicePublisher? {
		webService.requestSerializable(route: .postPatient(patient: patient), completion: completion)
	}

	@discardableResult
	func getRawReaults(route: APIRouter, completion: @escaping WebService.RequestCompletion<[String: Any]>) -> URLSession.ServicePublisher? {
		webService.requestSerializable(route: route, completion: completion)
	}

	// DeathRow
	@discardableResult
	func getQuestionnaire(completion: @escaping WebService.DecodableCompletion<Questionnaire>) -> URLSession.ServicePublisher? {
		webService.request(route: APIRouter.getQuestionnaire, completion: completion)
	}

	@discardableResult
	func postQuestionnaireResponse(questionnaireResponse: QuestionnaireResponse, completion: @escaping WebService.DecodableCompletion<SubmittedQuestionnaire>) -> URLSession.ServicePublisher? {
		webService.request(route: APIRouter.postQuestionnaireResponse(response: questionnaireResponse), completion: completion)
	}

	@discardableResult
	func getProfile(completion: @escaping WebService.DecodableCompletion<Profile>) -> URLSession.ServicePublisher? {
		webService.request(route: APIRouter.getProfile, completion: completion)
	}

	@discardableResult
	func postProfile(profile: Profile, completion: @escaping WebService.RequestCompletion<Bool>) -> URLSession.ServicePublisher? {
		webService.request(route: APIRouter.postProfile(profile: profile), completion: completion)
	}

	@discardableResult
	func patchPatient(patient: [UpdatePatientModel], completion: @escaping WebService.DecodableCompletion<CodexResource>) -> URLSession.ServicePublisher? {
		webService.request(route: APIRouter.patchPatient(patient: patient), completion: completion)
	}

	@discardableResult
	func getCardList(completion: @escaping WebService.DecodableCompletion<CardList>) -> URLSession.ServicePublisher? {
		webService.request(route: APIRouter.getNotifications, completion: completion)
	}

	@discardableResult
	func postBundle(bundle: ModelsR4.Bundle, completion: @escaping WebService.DecodableCompletion<ModelsR4.Bundle>) -> URLSession.ServicePublisher? {
		webService.request(route: APIRouter.postBundle(bundle: bundle), completion: completion)
	}

	@discardableResult
	func postObservationSearch(search: SearchParameter, completion: @escaping WebService.DecodableCompletion<CodexBundle>) -> URLSession.ServicePublisher? {
		webService.request(route: APIRouter.postObservationSearch(search: search), completion: completion)
	}
}
