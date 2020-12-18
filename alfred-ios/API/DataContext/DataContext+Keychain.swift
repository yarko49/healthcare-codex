import Foundation

extension DataContext {
	enum KeychainKey: String {
		case authToken = "AUTH_TOKEN"

		var key: String {
			rawValue
		}
	}

	var authToken: String? {
		get {
			Keychain.read(valueWithKey: KeychainKey.authToken.key)
		}
		set {
			guard let newValue = newValue else {
				Keychain.delete(valueWithKey: KeychainKey.authToken.key)
				return
			}
			Keychain.store(value: newValue, withKey: KeychainKey.authToken.key)
		}
	}

	func clearKeychain() {
		Keychain.logout()
	}
}
