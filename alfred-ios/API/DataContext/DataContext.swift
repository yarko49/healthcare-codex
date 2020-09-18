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
    
    var hasSmartScale = false
    var hasSmartBlockPressureCuff = false
    var hasSmartWatch = false
    var hasSmartPedometer = false
    var activityPushNotificationsIsOn = false
    var bloodPressurePushNotificationsIsOn = false
    var weightInPushNotificationsIsOn = false
    var surveyPushNotificationsIsOn = false
    
    func clearAll() {
      clearKeychain()
    }
}
