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
    
    static func postObservation(observation: Resource, completion: @escaping (Resource?)->Void) {
        sessionManager.request(APIRouter.postObservation(observation: observation))
            .validate().responseDecodableObject { (response: DataResponse<Resource>) in
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
    
    static func postProfile(profile : ProfileModel, completion: @escaping (Bool)-> Void) {
        sessionManager.request(APIRouter.postProfile(profile: profile))
            .validate().response{(response) in
                if response.error == nil {
                    print("201 Created")
                    completion(true)
                } else {
                    print(response.error ?? "Failed to complete request")
                    completion(false)
                }
            }
    }
  
    static func postPatient(patient : Resource, completion: @escaping (Resource?)->Void) {
        sessionManager.request(APIRouter.postPatient(patient: patient))
            .validate().responseDecodableObject { (response: DataResponse<Resource>) in
                switch response.result {
                case .success(let patientResponse):
                    response.data?.prettyPrint()
                    completion(patientResponse)
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(nil)
                    break
                }
            }
    }
    
    static func postPatientSearch( completion: @escaping (BundleModel?)->Void) {
        sessionManager.request(APIRouter.postPatientSearch)
            .validate().responseDecodableObject { (response: DataResponse<BundleModel>) in
                switch response.result {
                case .success(let patientResponse):
                    response.data?.prettyPrint()
                    completion(patientResponse)
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(nil)
                    break
                }
            }
    }
    
    
    static func getNotifications(completion: @escaping (CardList?) -> Void) {
        sessionManager.request(APIRouter.getNotifications).validate().responseDecodableObject { (response: DataResponse<CardList>) in
            switch response.result {
            case .success(let value):
                completion(value)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    static func getProfile(completion: @escaping (ProfileModel?) -> Void) {
        sessionManager.request(APIRouter.getProfile).validate().responseDecodableObject { (response: DataResponse<ProfileModel>) in
            switch response.result {
            case .success(let profile):
                completion(profile)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    static func postBundle(bundle: BundleModel, completion: @escaping (BundleModel?)->Void) {
        sessionManager.request(APIRouter.postBundle(bundle: bundle))
            .validate().responseDecodableObject { (response: DataResponse<BundleModel>) in
                switch response.result {
                case .success(let bundle):
                    response.data?.prettyPrint()
                    completion(bundle)
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(nil)
                    break
                }
        }
    }
    
}
