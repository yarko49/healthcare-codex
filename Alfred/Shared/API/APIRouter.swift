import Foundation

enum APIRouter: URLRequestConvertible {
	static let baseURLPath = AppConfig.apiBaseUrl

	case getCarePlan(vectorClock: Bool, valueSpaceSample: Bool)
	case getQuestionnaire
	case postQuestionnaireResponse(response: QuestionnaireResponse)
	case postPatient(patient: CodexResource)
	case getProfile
	case postProfile(profile: Profile)
	case postObservation(observation: CodexResource)
	case getNotifications
	case postPatientSearch
	case postBundle(bundle: CodexBundle)
	case postObservationSearch(search: SearchParameter)
	case patchPatient(patient: UpdatePatientModels)

	var method: Request.Method {
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
		default:
			data = nil
		}
		return data
	}

	var headers: [String: String] {
		var headers = [Request.Header.contentType: Request.ContentType.json,
		               Request.Header.xAPIKey: AppConfig.apiKey]
		if let authToken = DataContext.shared.authToken {
			headers[Request.Header.userAuthorization] = "Bearer " + authToken
		}
		switch self {
		case .getCarePlan(let vectorClock, let valueSpaceSample):
			if vectorClock {
				headers[Request.Header.CarePlanVectorClockOnly] = "true"
			} else if valueSpaceSample {
				headers[Request.Header.CarePlanPrefer] = "return=ValueSpaceSample"
			}
		case .getQuestionnaire, .getNotifications, .getProfile, .postProfile:
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
		case .getQuestionnaire, .postQuestionnaireResponse, .postObservation, .postPatient, .getProfile, .postProfile, .getNotifications, .postPatientSearch, .postBundle, .postObservationSearch, .patchPatient, .getCarePlan:
			return nil
		}
	}

	var request: Request? {
		guard let url = URL(string: APIRouter.baseURLPath)?.appendingPathComponent(path) else {
			return nil
		}
		var request = Request(method, url: url)
		request.setHeaders(headers)
		if let body = body {
			request.setJSONData(body)
		}
		return request
	}

	var urlRequest: URLRequest? {
		request?.urlRequest
	}
}
