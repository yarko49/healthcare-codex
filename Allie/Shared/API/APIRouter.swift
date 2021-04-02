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
	case postBundle(bundle: ModelsR4.Bundle)

	var method: Request.Method {
		switch self {
		case .registerProvider: return .post
		case .getCarePlan: return .get
		case .postCarePlan: return .post
		case .postPatient: return .post
		case .postObservation: return .post
		case .postBundle: return .post
		}
	}

	var path: String {
		var path = "/mobile"
		switch self {
		case .registerProvider: path += "/organization/register"
		case .getCarePlan, .postCarePlan, .postPatient: path += "/carePlan"
		case .postObservation: path += "/fhir/Observation"
		case .postBundle: path += "/fhir/Bundle"
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
			let carePlan = CarePlanResponse(carePlans: [], patients: [patient], tasks: [], vectorClock: [:])
			data = try? encoder.encode(carePlan)
		case .postObservation(let observation):
			data = try? encoder.encode(observation)

		case .postBundle(let bundle):
			data = try? encoder.encode(bundle)
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

		case .postBundle:
			headers[Request.Header.contentType] = Request.ContentType.fhirjson
		}
		return headers
	}

	var parameters: [String: Any]? {
		switch self {
		case .registerProvider, .getCarePlan, .postCarePlan, .postPatient, .postObservation:
			return nil

		case .postBundle:
			return nil
		}
	}

	var queryParameters: [URLQueryItem]? {
		nil
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
