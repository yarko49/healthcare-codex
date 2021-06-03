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

	case organizations
	case registerOrganization(Organization)
	case getCarePlan(option: CarePlanResponseType)
	case postCarePlan(carePlanResponse: CarePlanResponse)
	case postPatient(patient: AlliePatient)
	case postObservation(observation: ModelsR4.Observation)
	case postBundle(bundle: ModelsR4.Bundle)
	case postOutcomes(outcomes: [Outcome])
	case getFeatureContent(carePlanId: String, taskId: String, asset: String)

	var method: Request.Method {
		switch self {
		case .organizations:
			return .get
		case .registerOrganization:
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
		case .getFeatureContent:
			return .get
		}
	}

	var path: String {
		var path = "/mobile"
		switch self {
		case .organizations:
			path += "/organizations"
		case .registerOrganization:
			path += "/organization/register"
		case .getCarePlan, .postCarePlan, .postPatient:
			path += "/carePlan"
		case .postObservation:
			path += "/fhir/Observation"
		case .postBundle:
			path += "/fhir/Bundle"
		case .postOutcomes:
			path += "/carePlan/outcomes"
		case .getFeatureContent(let carePlanId, let taskId, let asset):
			path += "/carePlan/\(carePlanId)/task/\(taskId)/asset/\(asset)"
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
		case .registerOrganization(let organization):
			data = try? encoder.encode(organization)
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
		case .organizations:
			break
		case .registerOrganization:
			break
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
		case .postCarePlan, .postPatient:
			break
		case .postObservation:
			headers[Request.Header.contentType] = Request.ContentType.fhirjson
		case .postBundle:
			headers[Request.Header.contentType] = Request.ContentType.fhirjson
		case .postOutcomes:
			break
		case .getFeatureContent:
			break
		}
		return headers
	}

	var parameters: [String: Any]? {
		switch self {
		case .organizations:
			return nil
		case .registerOrganization:
			return nil
		case .getCarePlan, .postCarePlan, .postPatient, .postObservation:
			return nil
		case .postBundle:
			return nil
		case .postOutcomes:
			return nil
		case .getFeatureContent:
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
