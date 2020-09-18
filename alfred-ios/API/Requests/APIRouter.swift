import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible {
    static let baseURLPath = AppConfig.apiBaseUrl
    
    case getQuestionnaire
    case postObservation(observation: ObservationBE)
    
    var method: HTTPMethod {
        switch self {
        case .getQuestionnaire: return .get
        case .postObservation: return .post
        }
    }
    
    var path: String {
        switch self {
        case .getQuestionnaire: return "/fhir/Questionnaire"
        case .postObservation: return "/fhir/Observation"
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
    
    var headers: [String : String] {
        var headers = [
            "Content-Type": "application/json",
            "x-api-key": AppConfig.apiKey
        ]
        if let authToken = DataContext.shared.authToken {
            headers["Authorization"] = "Bearer " + authToken
        }
        switch self {
        case .getQuestionnaire:
            break
        case .postObservation:
            headers["Content-Type"] = "application/fhir+json"
        }
        return headers
    }
    
    var parameters: Parameters? {
        switch self {
        case .getQuestionnaire, .postObservation:
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
        default:
            break
        }
        
        return try encoding.encode(request, with: parameters)
    }
}
