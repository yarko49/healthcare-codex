//
//  APIRouter.swift
//  Allie
//
//  Created by Waqar Malik on 12/16/20.
//

import Foundation

enum APIRouter: URLRequestConvertible {
	static let baseURLPath = AppConfig.apiBaseUrl

	case getCarePlan(vectorClock: Bool, valueSpaceSample: Bool)
	case postCarePlan(carePlanResponse: CarePlanResponse)
	case registerProvider(HealthCareProvider)
	case getQuestionnaire
	case postQuestionnaireResponse(response: QuestionnaireResponse)
	case postPatient(patient: CodexResource)
	case getProfile
	case postProfile(profile: Profile)
	case postObservation(observation: CodexResource)
	case getNotifications
	case postPatientSearch
	case getPatient(identifier: String)
	case postBundle(bundle: CodexBundle)
	case postObservationSearch(search: SearchParameter)
	case patchPatient(patient: UpdatePatientModels)

	var method: Request.Method {
		switch self {
		case .getCarePlan: return .get
		case .postCarePlan: return .post
		case .registerProvider: return .post
		case .getQuestionnaire: return .get
		case .postQuestionnaireResponse: return .post
		case .postObservation: return .post
		case .postPatient: return .post
		case .getProfile: return .get
		case .postProfile: return .post
		case .getNotifications: return .get
		case .postPatientSearch: return .post
		case .getPatient: return .get
		case .postBundle: return .post
		case .postObservationSearch: return .post
		case .patchPatient: return .patch
		}
	}

	var path: String {
		switch self {
		case .getCarePlan, .postCarePlan: return "/carePlan"
		case .registerProvider: return "/mobile/organization/register"
		case .getQuestionnaire: return "/fhir/Questionnaire"
		case .postQuestionnaireResponse: return "/fhir/QuestionnaireResponse"
		case .postObservation: return "/fhir/Observation"
		case .postPatient: return "/fhir/Patient"
		case .getProfile, .postProfile: return "/profile"
		case .getNotifications: return "/notifications"
		case .postPatientSearch: return "/fhir/Patient/_search"
		case .postBundle: return "/fhir/Bundle"
		case .postObservationSearch: return "/fhir/Observation/_search"
		case .patchPatient: return "/fhir/Patient"
		case .getPatient: return "/fhir/Patient"
		}
	}

	var encoding: Request.ParameterEncoding {
		switch method {
		case .post:
			return .json
		default:
			return .percent
		}
	}

	var body: Data? {
		var data: Data?
		switch self {
		case .postObservation(let observation):
			data = try? JSONEncoder().encode(observation)
		case .postPatient(let patient):
			data = try? JSONEncoder().encode(patient)
		case .postProfile(let profile):
			data = try? JSONEncoder().encode(profile)
		case .postBundle(let bundle):
			data = try? JSONEncoder().encode(bundle)
		case .postObservationSearch(let search):
			data = try? JSONEncoder().encode(search)
		case .postQuestionnaireResponse(let response):
			data = try? JSONEncoder().encode(response)
		case .patchPatient(let editResponse):
			data = try? JSONEncoder().encode(editResponse)
		case .postCarePlan(let carePlanResponse):
			data = try? JSONEncoder().encode(carePlanResponse)
		case .registerProvider(let provider):
			data = try? JSONEncoder().encode(provider)
		default:
			data = nil
		}
		return data
	}

	var headers: [String: String] {
		var headers = [Request.Header.contentType: Request.ContentType.json,
		               Request.Header.xAPIKey: AppConfig.apiKey]
		if let authToken = Keychain.authToken {
			headers[Request.Header.userAuthorization] = "Bearer " + authToken
		}
		switch self {
		case .getCarePlan(let vectorClock, let valueSpaceSample):
			if vectorClock {
				headers[Request.Header.CarePlanVectorClockOnly] = "true"
			} else if valueSpaceSample {
				headers[Request.Header.CarePlanPrefer] = "return=ValueSpaceSample"
			}
		case .getQuestionnaire, .getNotifications, .getProfile, .postProfile, .postCarePlan, .registerProvider, .getPatient:
			break
		case .postObservation, .postPatient, .postPatientSearch, .postBundle, .postQuestionnaireResponse, .postObservationSearch:
			headers[Request.Header.contentType] = Request.ContentType.fhirjson
		case .patchPatient:
			headers[Request.Header.contentType] = Request.ContentType.patchjson
		}
		return headers
	}

	var parameters: [String: Any]? {
		switch self {
		case .getQuestionnaire, .postQuestionnaireResponse, .postObservation, .postPatient, .getProfile, .postProfile, .getNotifications, .postPatientSearch, .postBundle, .postObservationSearch, .patchPatient, .getCarePlan, .postCarePlan, .registerProvider, .getPatient:
			return nil
		}
	}

	var queryParameters: [URLQueryItem]? {
		switch self {
		case .getPatient(let identifier):
			return [URLQueryItem(name: "identifier", value: identifier)]
		default:
			return nil
		}
	}

	var request: Request? {
		guard let url = URL(string: APIRouter.baseURLPath)?.appendingPathComponent(path) else {
			return nil
		}
		var request = Request(method, url: url)
		request.setHeaders(headers)
		if let queryItems = queryParameters {
			request.setQueryItems(queryItems)
		}
		if let body = body {
			request.setJSONData(body)
		}
		return request
	}

	var urlRequest: URLRequest? {
		request?.urlRequest
	}
}
