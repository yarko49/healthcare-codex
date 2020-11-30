import Alamofire
import CodableAlamofire
import Foundation

class Requests {
	static let sessionManager: SessionManager = {
		let configuration = URLSessionConfiguration.default
		configuration.httpMaximumConnectionsPerHost = 50
		configuration.timeoutIntervalForRequest = 120
		let sessMan = SessionManager(configuration: configuration)
        let retrier = Interceptor()
        sessMan.retrier = retrier
        sessMan.adapter = retrier
		return sessMan
	}()

	static func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
		completion(true)
	}

	static func getQuestionnaire(completion: @escaping (Questionnaire?) -> Void) {
		sessionManager.request(APIRouter.getQuestionnaire).validate().responseDecodableObject { (response: DataResponse<Questionnaire>) in
			switch response.result {
			case .success(let value):
				completion(value)
			case .failure(let error):
				print(error)
				completion(nil)
			}
		}
	}

	static func postQuestionnaireResponse(questionnaireResponse: QuestionnaireResponse, completion: @escaping (SubmittedQuestionnaire?) -> Void) {
		sessionManager.request(APIRouter.postQuestionnaireResponse(response: questionnaireResponse))
			.validate().responseDecodableObject { (response: DataResponse<SubmittedQuestionnaire>) in
				switch response.result {
				case .success(let submissionResponse):
					// response.data?.prettyPrint()
					completion(submissionResponse)
				case .failure(let error):
					print(error.localizedDescription)
					completion(nil)
				}
			}
	}

	static func postObservation(observation: Resource, completion: @escaping (Resource?) -> Void) {
		sessionManager.request(APIRouter.postObservation(observation: observation))
			.validate().responseDecodableObject { (response: DataResponse<Resource>) in
				switch response.result {
				case .success(let observationResponse):
					// response.data?.prettyPrint()
					completion(observationResponse)
				case .failure(let error):
					print(error.localizedDescription)
					completion(nil)
				}
			}
	}

	static func postProfile(profile: ProfileModel, completion: @escaping (Bool) -> Void) {
		sessionManager.request(APIRouter.postProfile(profile: profile))
			.validate().response { response in
				if response.error == nil {
					print("201 Created")
					completion(true)
				} else {
					print(response.error ?? "Failed to complete request")
					completion(false)
				}
			}
	}

	static func postPatient(patient: Resource, completion: @escaping (Resource?) -> Void) {
		sessionManager.request(APIRouter.postPatient(patient: patient))
			.validate().responseDecodableObject { (response: DataResponse<Resource>) in
				switch response.result {
				case .success(let patientResponse):
					// response.data?.prettyPrint()
					completion(patientResponse)
				case .failure(let error):
					print(error.localizedDescription)
					completion(nil)
				}
			}
	}

	static func postPatientSearch(completion: @escaping (BundleModel?) -> Void) {
		sessionManager.request(APIRouter.postPatientSearch)
			.validate().responseDecodableObject { (response: DataResponse<BundleModel>) in
				switch response.result {
				case .success(let patientResponse):
					// response.data?.prettyPrint()
					completion(patientResponse)
				case .failure(let error):
					print(error.localizedDescription)
					completion(nil)
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

	static func postBundle(bundle: BundleModel, completion: @escaping (BundleModel?) -> Void) {
		sessionManager.request(APIRouter.postBundle(bundle: bundle))
			.validate().responseDecodableObject { (response: DataResponse<BundleModel>) in
				switch response.result {
				case .success(let bundle):
					// response.data?.prettyPrint()
					completion(bundle)
				case .failure(let error):
					print(error.localizedDescription)
					completion(nil)
				}
			}
	}

	static func postObservationSearch(search: SearchParameter, completion: @escaping (BundleModel?) -> Void) {
		sessionManager.request(APIRouter.postObservationSearch(search: search))
			.validate().responseDecodableObject { (response: DataResponse<BundleModel>) in
				switch response.result {
				case .success(let bundle):
					// response.data?.prettyPrint()
					completion(bundle)
				case .failure(let error):
					print(error.localizedDescription)
					completion(nil)
				}
			}
	}

	static func patchPatient(patient: [UpdatePatientModel], completion: @escaping (Resource?) -> Void) {
		sessionManager.request(APIRouter.patchPatient(patient: patient))
			.validate().responseDecodableObject { (response: DataResponse<Resource>) in
				switch response.result {
				case .success(let resource):
					// response.data?.prettyPrint()
					completion(resource)
				case .failure(let error):
					print(error.localizedDescription)
					completion(nil)
				}
			}
	}
}
