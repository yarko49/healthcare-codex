import Alamofire
import Foundation

enum APIRouter: URLRequestConvertible {
	static let baseURLPath = AppConfig.apiBaseUrl

	case getQuestionnaire
	case postQuestionnaireResponse(response: QuestionnaireResponse)
	case postPatient(patient: Resource)
	case getProfile
	case postProfile(profile: ProfileModel)
	case postObservation(observation: Resource)
	case getNotifications
	case postPatientSearch
	case postBundle(bundle: BundleModel)
	case postObservationSearch(search: SearchParameter)
	case patchPatient(patient: Edit)

	var method: HTTPMethod {
		switch self {
		case .getQuestionnaire: return .get
		case .postQuestionnaireResponse: return .post
		case .postObservation: return .post
		case .postPatient: return .post
		case .getProfile: return .get
		case .postProfile: return .post
		case .getNotifications: return .get
		case .postPatientSearch: return .post
		case .postBundle: return .post
		case .postObservationSearch: return .post
		case .patchPatient: return .patch
		}
	}

	var path: String {
		switch self {
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
		}
	}

	var encoding: ParameterEncoding {
		switch method {
		case .post:
			return JSONEncoding.default
		default:
			return URLEncoding.queryString
		}
	}

	var headers: [String: String] {
		var headers = [
			"Content-Type": "application/json",
			"x-api-key": AppConfig.apiKey,
		]
		if let authToken = DataContext.shared.authToken {
			headers["Authorization"] = "Bearer " + authToken
		}
		switch self {
		case .getQuestionnaire, .getNotifications, .getProfile, .postProfile:
			break
		case .postObservation, .postPatient, .postPatientSearch, .postBundle, .postQuestionnaireResponse, .postObservationSearch:
			headers["Content-Type"] = "application/fhir+json"
		case .patchPatient:
			headers["Content-Type"] = "application/json-patch+json"
		}
		return headers
	}

	var parameters: Parameters? {
		switch self {
		case .getQuestionnaire, .postQuestionnaireResponse, .postObservation, .postPatient, .getProfile, .postProfile, .getNotifications, .postPatientSearch, .postBundle, .postObservationSearch, .patchPatient:
			return nil
		}
	}

	public func asURLRequest() throws -> URLRequest {
		let url = try APIRouter.baseURLPath.asURL()

		var request = URLRequest(url: url.appendingPathComponent(path))
		request.httpMethod = method.rawValue
		request.allHTTPHeaderFields = headers

		switch self {
		case .postObservation(let observation):
			let jsonBody = try JSONEncoder().encode(observation)
			request.httpBody = jsonBody
		case .postPatient(let patient):
			let jsonBody = try JSONEncoder().encode(patient)
			request.httpBody = jsonBody
		case .postProfile(let profile):
			let jsonBody = try JSONEncoder().encode(profile)
			request.httpBody = jsonBody
		case .postBundle(let bundle):
			let jsonBody = try JSONEncoder().encode(bundle)
			request.httpBody = jsonBody
		case .postObservationSearch(let search):
			let jsonBody = try JSONEncoder().encode(search)
			request.httpBody = jsonBody
		case .postQuestionnaireResponse(let response):
			let jsonBody = try JSONEncoder().encode(response)
			request.httpBody = jsonBody
		case .patchPatient(let editResponse):
			let jsonBody = try JSONEncoder().encode(editResponse)
			request.httpBody = jsonBody

		default:
			break
		}
		return try encoding.encode(request, with: parameters)
	}
}
