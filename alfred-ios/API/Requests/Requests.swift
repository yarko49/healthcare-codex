import Foundation
import Alamofire
import CodableAlamofire

class Requests {
    
    static let sessionManager: SessionManager = {
        let sessMan = SessionManager()
        sessMan.session.configuration.timeoutIntervalForRequest = 30
        return sessMan
    }()
    
    static func login(email: String, password: String, completion: @escaping (Bool)->Void) {
        completion(true)
    }
    
    static func getQuestionnaire(completion: @escaping (QuestionnaireResponse?) -> Void) {
        sessionManager.request(APIRouter.getQuestionnaire).validate().responseDecodableObject { (response: DataResponse<QuestionnaireResponse>) in
            switch response.result {
            case .success(let value):
                completion(value)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    static func postObservation(observation: ObservationBE, completion: @escaping (ObservationResponse?)->Void) {
        sessionManager.request(APIRouter.postObservation(observation: observation))
            .validate().responseDecodableObject { (response: DataResponse<ObservationResponse>) in
                switch response.result {
                case .success(let observationResponse):
                    response.data?.prettyPrint()
                    completion(observationResponse)
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(nil)
                    break
                }
        }
    }
}
