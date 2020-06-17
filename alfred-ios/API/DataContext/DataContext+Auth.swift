import Foundation

extension DataContext {
    func login(withEmail email: String, andPassword password: String, completion: @escaping (Bool) -> Void) {
        // DO STUFF
        // ASYNCAFTER USED FOR EXAMPLE PURPOSES
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            Requests.login(email: email, password: password, completion: { (success) in
                completion(success)
               
            })
        }
    }
    
    func register(withEmail email: String, password: String, andConfirmPassword confirmPassword: String, completion: @escaping (Bool) -> Void) {
        // DO STUFF
        // ASYNCAFTER USED FOR EXAMPLE PURPOSES
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            completion(true)
        }
    }
    
    func logout(completion: @escaping (Bool)->Void) {
        // DO STUFF
        // ASYNCAFTER USED FOR EXAMPLE PURPOSES
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            completion(true)
        }
    }
}
