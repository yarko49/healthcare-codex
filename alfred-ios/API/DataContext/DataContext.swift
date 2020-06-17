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
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            completion(true)
        }
    }
   
    func clearAll() {
      clearKeychain()
    }
}
