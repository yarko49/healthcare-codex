import Foundation
import HealthKit

extension DataContext {
    
    func createProfileModel() -> ProfileModel {
        let device = HKDevice.local()
        let dateNow = DateFormatter.yyyyMMddTHHmmssDashed.string(from: Date())
        
        let diastolicBP = DiastolicBloodPressure(notificationsEnabled: DataContext.shared.bloodPressurePushNotificationsIsOn , available: DataContext.shared.hasSmartBlockPressureCuff)
        let heartRate = DiastolicBloodPressure(notificationsEnabled: DataContext.shared.surveyPushNotificationsIsOn , available: DataContext.shared.hasSmartWatch)
        let restingHR = DiastolicBloodPressure(notificationsEnabled: DataContext.shared.surveyPushNotificationsIsOn , available: DataContext.shared.hasSmartWatch)
        let steps = DiastolicBloodPressure(notificationsEnabled: DataContext.shared.activityPushNotificationsIsOn , available: DataContext.shared.hasSmartPedometer || DataContext.shared.hasSmartWatch)
        let systolicBP = DiastolicBloodPressure(notificationsEnabled: DataContext.shared.bloodPressurePushNotificationsIsOn , available: DataContext.shared.hasSmartBlockPressureCuff)
        let weight = DiastolicBloodPressure(notificationsEnabled: DataContext.shared.weightInPushNotificationsIsOn , available: DataContext.shared.hasSmartScale)
        
        let healthMeasurements = HealthMeasurements(diastolicBloodPressure: diastolicBP, heartRate: heartRate, restingHeartRate: restingHR, steps: steps, systolicBloodPressure: systolicBP, weight: weight)
        
        let additionalProp1 = AdditionalProp(deviceModel: device.model ?? "", deviceVersion: device.firmwareVersion ?? "", id: device.udiDeviceIdentifier ?? "", lastSyncTime: dateNow, manufacturer: "Apple", softwareName: "software", softwareVersion: device.softwareVersion ?? "")
        let devices = Devices(additionalProp1: additionalProp1, additionalProp2: AdditionalProp(deviceModel: "", deviceVersion: "", id: "", lastSyncTime: dateNow, manufacturer: "", softwareName: "", softwareVersion: ""), additionalProp3: AdditionalProp(deviceModel: "", deviceVersion: "", id: "", lastSyncTime: dateNow, manufacturer: "", softwareName: "", softwareVersion: ""))
        
        let profile = ProfileModel(notificationsEnabled: true, registrationToken: "", healthMeasurements: healthMeasurements, devices: devices, signUpCompleted: signUpCompleted)
        
        print(profile)
        return profile
    }
    
    func getQuestionnaire(completion: @escaping ([Item]?)->Void) {
        Requests.getQuestionnaire { (questionnaire) in
            if let questionnaire = questionnaire?.item {
                completion(questionnaire)
            } else {
                completion(nil)
            }
        }
    }
    
    func postProfile(profile: ProfileModel, completion: @escaping (Bool)->Void) {
        Requests.postProfile(profile: profile) {(result) in
            completion(result)
        }
    }
    
    func postPatient(patient: Resource, completion: @escaping (Resource?)->Void) {
        Requests.postPatient(patient: patient){(patientResponse) in
            if let patientResponse = patientResponse {
                completion(patientResponse)
            } else {
                completion(nil)
            }
        }
    }
    
    func postPatientSearch(completion: @escaping (BundleModel?)->Void) {
        Requests.postPatientSearch {(patientResponse) in
               if let patientResponse = patientResponse {
                   completion(patientResponse)
               } else {
                   completion(nil)
               }
           }
    }
    
    func getProfile(completion: @escaping (ProfileModel?)->Void) {
        Requests.getProfile { (profile) in
            if let profile = profile {
                completion(profile)
            } else {
                completion(nil)
            }
        }
    }
    
    func getNotifications(completion: @escaping ([NotificationCard]?)->Void) {
        Requests.getNotifications { (cardList) in
            if let cardList = cardList?.notifications {
                completion(cardList)
            } else {
                completion(nil)
            }
        }
    }
    
    func postObservation(observation: Resource, completion: @escaping (Resource?)->Void) {
        Requests.postObservation(observation: observation) { (observationResponse) in
            if let response = observationResponse {
                completion(response)
            } else {
                completion(nil)
            }
        }
    }
    
    func postBundle(bundle: BundleModel, completion: @escaping (BundleModel?)->Void) {
        Requests.postBundle(bundle: bundle) { (bundleResponse) in
            if let response = bundleResponse {
                completion(response)
            } else {
                completion(nil)
            }
        }
    }
}
