import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible {
    static let baseURLPath = AppConfig.apiBaseUrl
    
    case test
    
    var method: HTTPMethod {
        switch self {
        case .test: return .get
        }
    }
    
    var path: String {
        switch self {
        case .test: return "/todos/1"
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
            "Content-Type": "application/json"
        ]
        switch self {
        case .test:
            headers["Some-Other-Header"] = "Some Other Value"
        }
        return headers
    }
    
    var parameters: Parameters? {
        switch self {
        case .test:
            return ["param": "value"]
        }
    }
    
    public func asURLRequest() throws -> URLRequest {
        let url = try APIRouter.baseURLPath.asURL()
        
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        
        return try encoding.encode(request, with: parameters)
    }
}
