//
//  APIRouter.swift
//  Allie
//
//  Created by Waqar Malik on 12/16/20.
//

import Foundation
import ModelsR4

enum APIRouter: URLRequestConvertible {
	static let baseURLPath = AppConfig.apiBaseUrl

	case registerProvider(HealthCareProvider)
	case getCarePlan(vectorClock: Bool, valueSpaceSample: Bool)
	case postCarePlan(carePlanResponse: CarePlanResponse)
	case postPatient(patient: AlliePatient)
	case postObservation(observation: ModelsR4.Observation)

	// DeathRow
	case getQuestionnaire
	case postQuestionnaireResponse(response: QuestionnaireResponse)
	case getProfile
	case postProfile(profile: Profile)
	case getNotifications
	case getPatient(identifier: String)
	case postBundle(bundle: ModelsR4.Bundle)
	case postObservationSearch(search: SearchParameter)
	case patchPatient(patient: UpdatePatientModels)

	var method: Request.Method {
		switch self {
		case .registerProvider: return .post
		case .getCarePlan: return .get
		case .postCarePlan: return .post
		case .postPatient: return .post
		case .postObservation: return .post

		case .getQuestionnaire: return .get
		case .postQuestionnaireResponse: return .post
		case .getProfile: return .get
		case .postProfile: return .post
		case .getNotifications: return .get
		case .getPatient: return .get
		case .postBundle: return .post
		case .postObservationSearch: return .post
		case .patchPatient: return .patch
		}
	}

	var path: String {
		var path = "/mobile"
		switch self {
		case .registerProvider: path += "/organization/register"
		case .getCarePlan, .postCarePlan, .postPatient: path += "/carePlan"
		case .postObservation: path += "/fhir/Observation"

		case .getQuestionnaire: path += "/fhir/Questionnaire"
		case .postQuestionnaireResponse: path += "/fhir/QuestionnaireResponse"
		case .getProfile, .postProfile: path += "/profile"
		case .getNotifications: path += "/notifications"
		case .postBundle: path += "/fhir/Bundle"
		case .postObservationSearch: path += "/fhir/Observation/_search"
		case .patchPatient: path += "/fhir/Patient"
		case .getPatient: path += "/fhir/Patient"
		}

		return path
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
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601

		switch self {
		case .registerProvider(let provider):
			data = try? encoder.encode(provider)
		case .postCarePlan(let carePlanResponse):
			data = try? encoder.encode(carePlanResponse)
		case .postPatient(let patient):
			let carePlan = CarePlanResponse(carePlans: [:], patients: [patient.id: patient], tasks: [:], vectorClock: [:])
			data = try? encoder.encode(carePlan)
		case .postObservation(let observation):
			data = try? encoder.encode(observation)

		case .postProfile(let profile):
			data = try? encoder.encode(profile)
		case .postBundle(let bundle):
			data = try? encoder.encode(bundle)
		case .postObservationSearch(let search):
			data = try? encoder.encode(search)
		case .postQuestionnaireResponse(let response):
			data = try? encoder.encode(response)
		case .patchPatient(let editResponse):
			data = try? encoder.encode(editResponse)
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
		case .registerProvider, .postCarePlan, .postPatient:
			break
		case .postObservation:
			headers[Request.Header.contentType] = Request.ContentType.fhirjson

		case .getQuestionnaire, .getNotifications, .getProfile, .postProfile, .getPatient:
			break
		case .postBundle, .postQuestionnaireResponse, .postObservationSearch:
			headers[Request.Header.contentType] = Request.ContentType.fhirjson
		case .patchPatient:
			headers[Request.Header.contentType] = Request.ContentType.patchjson
		}
		return headers
	}

	var parameters: [String: Any]? {
		switch self {
		case .registerProvider, .getCarePlan, .postCarePlan, .postPatient, .postObservation:
			return nil

		case .getQuestionnaire, .postQuestionnaireResponse, .getProfile, .postProfile, .getNotifications, .postBundle, .postObservationSearch, .patchPatient, .getPatient:
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
