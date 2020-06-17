import Foundation
import Alamofire

class Requests {
    static func login(email: String, password: String, completion: @escaping (Bool)->Void) {
        completion(true)
    }
    
    static func testRequest(completion: @escaping ([String:Any]?)->Void) {
        Alamofire.request(APIRouter.test).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                completion(value as? [String:Any])
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
}
