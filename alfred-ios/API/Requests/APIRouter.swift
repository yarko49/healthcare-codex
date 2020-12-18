import Alamofire
import AlfredCore
import Foundation

enum APIRouter: URLRequestConvertible {
	static let baseURLPath = AppConfig.apiBaseUrl

	case getCarePlan(vectorClock: Bool, valueSpaceSample: Bool)
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
		case .getCarePlan: return .get
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
		case .getCarePlan: return "/carePlan"
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
		var headers = [AlfredCore.Request.Header.contentType: AlfredCore.Request.ContentType.json,
		               AlfredCore.Request.Header.xAPIKey: AppConfig.apiKey]
		if let authToken = DataContext.shared.authToken {
			headers[AlfredCore.Request.Header.userAuthorization] = "Bearer " + authToken
		}
		switch self {
		case .getCarePlan(let vectorClock, let valueSpaceSample):
			if vectorClock {
				headers[AlfredCore.Request.Header.CarePlanVectorClockOnly] = "true"
			} else if valueSpaceSample {
				headers[AlfredCore.Request.Header.CarePlanPrefer] = "return=ValueSpaceSample"
			}
		case .getQuestionnaire, .getNotifications, .getProfile, .postProfile:
			break
		case .postObservation, .postPatient, .postPatientSearch, .postBundle, .postQuestionnaireResponse, .postObservationSearch:
			headers[AlfredCore.Request.Header.contentType] = AlfredCore.Request.ContentType.fhirjson
		case .patchPatient:
			headers[AlfredCore.Request.Header.contentType] = AlfredCore.Request.ContentType.patchjson
		}
		return headers
	}

	var parameters: Parameters? {
		switch self {
		case .getQuestionnaire, .postQuestionnaireResponse, .postObservation, .postPatient, .getProfile, .postProfile, .getNotifications, .postPatientSearch, .postBundle, .postObservationSearch, .patchPatient, .getCarePlan:
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
