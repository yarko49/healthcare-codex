//
//  APIRouter.swift
//  Allie
//
//  Created by Waqar Malik on 12/16/20.
//

import CodexFoundation
import CodexModel
import Foundation
import KeychainAccess
import ModelsR4
import WebService

public enum CarePlanResponseType: Hashable {
	case carePlan
	case summary
	case outcomes
	case valueSpaceSample
	case vectorClock
}

enum APIRouter {
	static let baseURLPath = AppConfig.apiBaseUrl
	@Injected(\.keychain) static var keychain: Keychain
	static var authToken: String? {
		keychain.authenticationToken?.token
	}

	case organizations
	case registerOrganization(CMOrganization)
	case unregisterOrganization(CMOrganization)
	case conversationsTokens
	case postConversationsUsers(String, [String])
	case getCarePlan(option: CarePlanResponseType)
	case postCarePlan(carePlanResponse: CHCarePlanResponse)
	case postPatient(patient: CHPatient)
	case postObservation(observation: ModelsR4.Observation)
	case postBundle(bundle: ModelsR4.Bundle)
	case postOutcomes(outcomes: [CHOutcome])
	case getOutcomes(carePlanId: String, taskId: String)
	case getFeatureContent(carePlanId: String, taskId: String, asset: String)
	case postNotificationToken(String)
	case integrations
	case postIntegration(CMCloudDevice)
	case deleteIntegration(CMCloudDevice)

	var method: Request.Method {
		switch self {
		case .organizations:
			return .GET
		case .registerOrganization:
			return .POST
		case .unregisterOrganization:
			return .DELETE
		case .conversationsTokens:
			return .GET
		case .postConversationsUsers:
			return .POST
		case .getCarePlan:
			return .GET
		case .postCarePlan:
			return .POST
		case .postPatient:
			return .POST
		case .postObservation:
			return .POST
		case .postBundle:
			return .POST
		case .postOutcomes:
			return .POST
		case .getOutcomes:
			return .GET
		case .getFeatureContent:
			return .GET
		case .postNotificationToken:
			return .POST
		case .integrations:
			return .GET
		case .postIntegration:
			return .POST
		case .deleteIntegration:
			return .DELETE
		}
	}

	var path: String {
		var path = "/mobile"
		switch self {
		case .organizations:
			path += "/organizations"
		case .registerOrganization:
			path += "/organization/register"
		case .unregisterOrganization:
			path += "/organization/register"
		case .conversationsTokens:
			path += "/conversations"
		case .postConversationsUsers(let organization, _):
			path += "/conversations/\(organization)/users"
		case .getCarePlan, .postCarePlan, .postPatient:
			path += "/carePlan"
		case .postObservation:
			path += "/fhir/Observation"
		case .postBundle:
			path += "/fhir/Bundle"
		case .postOutcomes:
			path += "/carePlan/outcomes"
		case .getOutcomes(let carePlanId, let taskId):
			path += "/carePlan/\(carePlanId)/task/\(taskId)/outcomes"
		case .getFeatureContent(let carePlanId, let taskId, let asset):
			path += "/carePlan/\(carePlanId)/task/\(taskId)/asset/\(asset)"
		case .postNotificationToken:
			path += "/notifications/token"
		case .integrations:
			path += "/integrations"
		case .postIntegration(let cloudDevice):
			path += "/integration/\(cloudDevice.id)"
		case .deleteIntegration(let cloudDevice):
			path += "/integration/\(cloudDevice.id)"
		}

		return path
	}

	var encoding: Request.ParameterEncoding {
		switch method {
		case .POST:
			return .json
		case .DELETE:
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
		case .unregisterOrganization(let organization):
			data = try? encoder.encode(organization)
		case .postCarePlan(let carePlanResponse):
			data = try? encoder.encode(carePlanResponse)
		case .postPatient(let patient):
			let carePlan = CHCarePlanResponse(patients: [patient])
			data = try? encoder.encode(carePlan)
		case .postObservation(let observation):
			data = try? encoder.encode(observation)
		case .postBundle(let bundle):
			data = try? encoder.encode(bundle)
		case .postOutcomes(let outcomes):
			let carePlan = CHCarePlanResponse(outcomes: outcomes)
			data = try? encoder.encode(carePlan)
		case .postConversationsUsers(_, let users):
			let requestObject = ["users": users]
			data = try? encoder.encode(requestObject)
		case .postNotificationToken(let token):
			let tokenRequest: [String: String] = ["timestamp": DateFormatter.wholeDateRequest.string(from: Date()), "token": token]
			data = try? encoder.encode(tokenRequest)
		case .postIntegration(let integraion):
			data = try? encoder.encode(integraion)
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
		case .unregisterOrganization:
			break
		case .conversationsTokens, .postConversationsUsers:
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
			case .outcomes: // Deprecated
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
		case .getOutcomes:
			break
		case .getFeatureContent:
			break
		case .postNotificationToken:
			break
		case .integrations, .postIntegration, .deleteIntegration:
			break
		}
		return headers
	}

	var parameters: [String: Any]? {
		switch self {
		case .organizations, .registerOrganization, .unregisterOrganization:
			return nil
		case .conversationsTokens, .postConversationsUsers:
			return nil
		case .getCarePlan, .postCarePlan, .postPatient, .postObservation:
			return nil
		case .postBundle:
			return nil
		case .postOutcomes:
			return nil
		case .getOutcomes:
			return nil
		case .getFeatureContent:
			return nil
		case .postNotificationToken:
			return nil
		case .integrations, .postIntegration, .deleteIntegration:
			return nil
		}
	}

	var queryParameters: [URLQueryItem]? {
		nil
	}
}

extension APIRouter: URLRequestEncodable {
	func url() throws -> URL {
		guard let url = URL(string: APIRouter.baseURLPath)?.appendingPathComponent(path) else {
			throw URLError(.badURL)
		}
		return url
	}

	func request() throws -> Request {
		let url = try url()
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

	func urlRequest() throws -> URLRequest {
		try request().urlRequest()
	}
}
