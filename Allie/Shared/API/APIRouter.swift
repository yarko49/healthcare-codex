//
//  APIRouter.swift
//  Allie
//
//  Created by Waqar Malik on 12/16/20.
//

import Foundation
import KeychainAccess
import ModelsR4

public enum CarePlanResponseType: Hashable {
	case carePlan
	case summary
	case outcomes
	case valueSpaceSample
	case vectorClock
}

enum APIRouter: URLRequestConvertible {
	static let baseURLPath = AppConfig.apiBaseUrl
	static var authToken: String? {
		Keychain.authenticationToken?.token
	}

	case registerProvider(HealthCareProvider)
	case getCarePlan(option: CarePlanResponseType)
	case postCarePlan(carePlanResponse: CarePlanResponse)
	case postPatient(patient: AlliePatient)
	case postObservation(observation: ModelsR4.Observation)
	case postBundle(bundle: ModelsR4.Bundle)
	case postOutcomes(outcomes: [Outcome])

	var method: Request.Method {
		switch self {
		case .registerProvider:
			return .post
		case .getCarePlan:
			return .get
		case .postCarePlan:
			return .post
		case .postPatient:
			return .post
		case .postObservation:
			return .post
		case .postBundle:
			return .post
		case .postOutcomes:
			return .post
		}
	}

	var path: String {
		var path = "/mobile"
		switch self {
		case .registerProvider:
			path += "/organization/register"
		case .getCarePlan, .postCarePlan, .postPatient:
			path += "/carePlan"
		case .postObservation:
			path += "/fhir/Observation"
		case .postBundle:
			path += "/fhir/Bundle"
		case .postOutcomes:
			path += "/carePlan/outcomes"
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
		encoder.dateEncodingStrategy = .iso8601WithFractionalSeconds

		switch self {
		case .registerProvider(let provider):
			data = try? encoder.encode(provider)
		case .postCarePlan(let carePlanResponse):
			data = try? encoder.encode(carePlanResponse)
		case .postPatient(let patient):
			let carePlan = CarePlanResponse(patients: [patient])
			data = try? encoder.encode(carePlan)
		case .postObservation(let observation):
			data = try? encoder.encode(observation)
		case .postBundle(let bundle):
			data = try? encoder.encode(bundle)
		case .postOutcomes(let outcomes):
			let carePlan = CarePlanResponse(outcomes: outcomes)
			data = try? encoder.encode(carePlan)
		default:
			data = nil
		}
		return data
	}

	var headers: [String: String] {
		var headers = [Request.Header.contentType: Request.ContentType.json,
		               Request.Header.xAPIKey: AppConfig.apiKey]
		if let authToken = Self.authToken {
			headers[Request.Header.userAuthorization] = "Bearer " + authToken
		}
		switch self {
		case .getCarePlan(let option):
			// possible values are return=Summary, return=Outcomes, return=ValueSpaceSample, return=VectorClock
			switch option {
			case .carePlan:
				break
			case .vectorClock:
				headers[Request.Header.CarePlanPrefer] = "return=VectorClock"
			case .valueSpaceSample:
				headers[Request.Header.CarePlanPrefer] = "return=ValueSpaceSample"
			case .outcomes:
				headers[Request.Header.CarePlanPrefer] = "return=Outcomes"
			case .summary:
				headers[Request.Header.CarePlanPrefer] = "return=Summary"
			}
		case .registerProvider, .postCarePlan, .postPatient:
			break
		case .postObservation:
			headers[Request.Header.contentType] = Request.ContentType.fhirjson
		case .postBundle:
			headers[Request.Header.contentType] = Request.ContentType.fhirjson
		case .postOutcomes:
			break
		}
		return headers
	}

	var parameters: [String: Any]? {
		switch self {
		case .registerProvider, .getCarePlan, .postCarePlan, .postPatient, .postObservation:
			return nil
		case .postBundle:
			return nil
		case .postOutcomes:
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
