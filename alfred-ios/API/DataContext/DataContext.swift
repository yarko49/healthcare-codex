import Foundation

class DataContext {
    static let shared = DataContext()

    
    var hasRunOnce: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "HAS_RUN_ONCE")
        }
        get {
            return UserDefaults.standard.bool(forKey: "HAS_RUN_ONCE")
        }
    }
   
    func initialize(completion: @escaping (Bool)->()) {
        // DO STUFF
        // ASYNCAFTER USED FOR EXAMPLE PURPOSES
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion(true)
        }
    }
    
    var hasCompletedOnboarding: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "HAS_COMPLETED_ONBOARDING")
        }
        get {
            return UserDefaults.standard.bool(forKey: "HAS_COMPLETED_ONBOARDING")
        }
    }
    
    var userAuthorizedQuantities: [HealthKitQuantityType] = [.weight, .activity, .bloodPressure, .restingHR, .heartRate]
    var healthKitIntervals : [HealthStatsDateIntervalType] = [.daily, .weekly, .monthly, .yearly]
   
    var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    var hasSmartScale = Bool()
    var hasSmartBlockPressureCuff = Bool()
    var hasSmartWatch =  Bool()
    var hasSmartPedometer =  Bool()
    var userModel : UserModel?
    //var signUpCompleted = Bool()
    
    
    var activityPushNotificationsIsOn = false
    var bloodPressurePushNotificationsIsOn = false
    var weightInPushNotificationsIsOn = false
    var surveyPushNotificationsIsOn = false
    var signUpCompleted = false
    
    func printModel(){
        print(userModel)
    }

    let weightCode = Code(coding: [Coding(system: "http://loinc.org", code: "29463-7", display: "Body weight"), Coding(system: "http://loinc.org", code: "3141-9", display: "Body weight measured"), Coding(system: "http://snomed.info/sct", code: "27113001", display: "Body weight")])
    
   let heightCode = Code(coding: [Coding(system: "http://loinc.org", code: "8302-2", display: "Body height")])
    
    let diastolicBPCode = Code(coding: [Coding(system: "http://loinc.org", code: "8462-4", display: "Diastolic blood pressure")])
    let systolicBPCode = Code(coding: [Coding(system: "http://loinc.org", code: "8480-6", display: "Systolic blood pressure"),Coding(system: "http://snomed.info/sct", code: "271649006", display: "Systolic blood pressure")])
    
    func clearAll() {
      clearKeychain()
    }
}
