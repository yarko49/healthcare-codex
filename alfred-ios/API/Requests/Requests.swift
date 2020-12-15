import Alamofire
import CodableAlamofire
import Foundation

class Requests {
	static let session: Session = {
		let configuration = URLSessionConfiguration.default
		configuration.httpMaximumConnectionsPerHost = 50
		configuration.timeoutIntervalForRequest = 120
		let interceptor = Interceptor()
		let session = Session(configuration: configuration, interceptor: interceptor)
		return session
	}()

	static func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
		completion(true)
	}

	static func getQuestionnaire(completion: @escaping (Questionnaire?) -> Void) {
		session.request(APIRouter.getQuestionnaire).validate().getResponseDecodableObject { (response: AFDataResponse<Questionnaire>) in
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
		session.request(APIRouter.postQuestionnaireResponse(response: questionnaireResponse))
			.validate().getResponseDecodableObject { (response: AFDataResponse<SubmittedQuestionnaire>) in
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
		session.request(APIRouter.postObservation(observation: observation))
			.validate().getResponseDecodableObject { (response: AFDataResponse<Resource>) in
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
		session.request(APIRouter.postProfile(profile: profile))
			.validate().getResponse { response in
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
		session.request(APIRouter.postPatient(patient: patient))
			.validate().getResponseDecodableObject { (response: AFDataResponse<Resource>) in
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
		session.request(APIRouter.postPatientSearch)
			.validate().getResponseDecodableObject { (response: AFDataResponse<BundleModel>) in
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
		session.request(APIRouter.getNotifications).validate().getResponseDecodableObject { (response: AFDataResponse<CardList>) in
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
		session.request(APIRouter.getProfile).validate().getResponseDecodableObject { (response: AFDataResponse<ProfileModel>) in
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
		session.request(APIRouter.postBundle(bundle: bundle))
			.validate().getResponseDecodableObject { (response: AFDataResponse<BundleModel>) in
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
		session.request(APIRouter.postObservationSearch(search: search))
			.validate().getResponseDecodableObject { (response: AFDataResponse<BundleModel>) in
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
		session.request(APIRouter.patchPatient(patient: patient))
			.validate().getResponseDecodableObject { (response: AFDataResponse<Resource>) in
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
