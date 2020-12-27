//
//  AlfredClient.swift
//  AlfredHealth
//
//  Created by Waqar Malik on 12/16/20.
//

import Combine
import Foundation

protocol AlfredAPI {
	func login(email: String, password: String, completion: @escaping WebService.DecodableCompletion<Bool>)
	func register(withEmail email: String, password: String, andConfirmPassword confirmPassword: String, completion: @escaping WebService.DecodableCompletion<Bool>)
	func logout(completion: @escaping WebService.DecodableCompletion<Bool>)
	func getCarePlan(vectorClock: Bool, valueSpaceSample: Bool, completion: @escaping WebService.DecodableCompletion<CarePlanResponse>) -> URLSession.DataTaskPublisher?
	func getQuestionnaire(completion: @escaping WebService.DecodableCompletion<Questionnaire>) -> URLSession.DataTaskPublisher?
	func postQuestionnaireResponse(questionnaireResponse: QuestionnaireResponse, completion: @escaping WebService.DecodableCompletion<SubmittedQuestionnaire>) -> URLSession.DataTaskPublisher?
	func postObservation(observation: Resource, completion: @escaping WebService.DecodableCompletion<Resource>) -> URLSession.DataTaskPublisher?
	func postProfile(profile: ProfileModel, completion: @escaping WebService.DecodableCompletion<ProfileModel>) -> URLSession.DataTaskPublisher?
	func postPatient(patient: Resource, completion: @escaping WebService.DecodableCompletion<Resource>) -> URLSession.DataTaskPublisher?
	func patchPatient(patient: [UpdatePatientModel], completion: @escaping WebService.DecodableCompletion<Resource>) -> URLSession.DataTaskPublisher?
	func postPatientSearch(completion: @escaping WebService.DecodableCompletion<BundleModel>) -> URLSession.DataTaskPublisher?
	func getCardList(completion: @escaping WebService.DecodableCompletion<CardList>) -> URLSession.DataTaskPublisher?
	func getProfile(completion: @escaping WebService.DecodableCompletion<ProfileModel>) -> URLSession.DataTaskPublisher?
	func postBundle(bundle: BundleModel, completion: @escaping WebService.DecodableCompletion<BundleModel>) -> URLSession.DataTaskPublisher?
	func postObservationSearch(search: SearchParameter, completion: @escaping WebService.DecodableCompletion<BundleModel>) -> URLSession.DataTaskPublisher?
}

public final class AlfredClient: AlfredAPI {
	static let client = AlfredClient()

	public var apiKey: String? {
		AppConfig.apiKey
	}

	public var authToken: String? {
		DataContext.shared.authToken
	}

	private let webService: WebService

	public init(session: URLSession = .shared) {
		session.configuration.httpMaximumConnectionsPerHost = 50
		session.configuration.timeoutIntervalForRequest = 120
		self.webService = WebService(session: session)
		webService.errorProcessor = { request, error in
			let errorToSend = error as NSError
			var userInfo = errorToSend.userInfo
			userInfo["message"] = error.localizedDescription
			if let url = request.url {
				userInfo["url"] = url
			}
			let crashlyticsError = NSError(domain: errorToSend.domain, code: errorToSend.code, userInfo: userInfo)
			DataContext.shared.logError(crashlyticsError)
		}
	}

	public func login(email: String, password: String, completion: @escaping WebService.DecodableCompletion<Bool>) {
		completion(.success(true))
	}

	func register(withEmail email: String, password: String, andConfirmPassword confirmPassword: String, completion: @escaping WebService.DecodableCompletion<Bool>) {
		completion(.success(true))
	}

	func logout(completion: @escaping WebService.DecodableCompletion<Bool>) {
		completion(.success(true))
	}

	@discardableResult
	public func getCarePlan(vectorClock: Bool = false, valueSpaceSample: Bool = false, completion: @escaping WebService.DecodableCompletion<CarePlanResponse>) -> URLSession.DataTaskPublisher? {
		let route = APIRouter.getCarePlan(vectorClock: vectorClock, valueSpaceSample: valueSpaceSample)
		return webService.request(route: route, completion: completion)
	}

	@discardableResult
	func getRawReaults(route: APIRouter, completion: @escaping WebService.RequestCompletion<[String: Any]>) -> URLSession.DataTaskPublisher? {
		webService.request(route: route, completion: completion)
	}

	@discardableResult
	func getQuestionnaire(completion: @escaping WebService.DecodableCompletion<Questionnaire>) -> URLSession.DataTaskPublisher? {
		webService.request(route: APIRouter.getQuestionnaire, completion: completion)
	}

	@discardableResult
	func postQuestionnaireResponse(questionnaireResponse: QuestionnaireResponse, completion: @escaping WebService.DecodableCompletion<SubmittedQuestionnaire>) -> URLSession.DataTaskPublisher? {
		webService.request(route: APIRouter.postQuestionnaireResponse(response: questionnaireResponse), completion: completion)
	}

	@discardableResult
	func postObservation(observation: Resource, completion: @escaping WebService.DecodableCompletion<Resource>) -> URLSession.DataTaskPublisher? {
		webService.request(route: APIRouter.postObservation(observation: observation), completion: completion)
	}

	@discardableResult
	func postProfile(profile: ProfileModel, completion: @escaping WebService.DecodableCompletion<ProfileModel>) -> URLSession.DataTaskPublisher? {
		webService.request(route: APIRouter.postProfile(profile: profile), completion: completion)
	}

	@discardableResult
	func postPatient(patient: Resource, completion: @escaping WebService.DecodableCompletion<Resource>) -> URLSession.DataTaskPublisher? {
		webService.request(route: APIRouter.postPatient(patient: patient), completion: completion)
	}

	@discardableResult
	func patchPatient(patient: [UpdatePatientModel], completion: @escaping WebService.DecodableCompletion<Resource>) -> URLSession.DataTaskPublisher? {
		webService.request(route: APIRouter.patchPatient(patient: patient), completion: completion)
	}

	@discardableResult
	func postPatientSearch(completion: @escaping WebService.DecodableCompletion<BundleModel>) -> URLSession.DataTaskPublisher? {
		webService.request(route: APIRouter.postPatientSearch, completion: completion)
	}

	@discardableResult
	func getCardList(completion: @escaping WebService.DecodableCompletion<CardList>) -> URLSession.DataTaskPublisher? {
		webService.request(route: APIRouter.getNotifications, completion: completion)
	}

	@discardableResult
	func getProfile(completion: @escaping WebService.DecodableCompletion<ProfileModel>) -> URLSession.DataTaskPublisher? {
		webService.request(route: APIRouter.getProfile, completion: completion)
	}

	@discardableResult
	func postBundle(bundle: BundleModel, completion: @escaping WebService.DecodableCompletion<BundleModel>) -> URLSession.DataTaskPublisher? {
		webService.request(route: APIRouter.postBundle(bundle: bundle), completion: completion)
	}

	@discardableResult
	func postObservationSearch(search: SearchParameter, completion: @escaping WebService.DecodableCompletion<BundleModel>) -> URLSession.DataTaskPublisher? {
		webService.request(route: APIRouter.postObservationSearch(search: search), completion: completion)
	}
}
