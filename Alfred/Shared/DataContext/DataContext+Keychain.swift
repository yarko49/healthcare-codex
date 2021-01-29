import FirebaseAuth
import Foundation

extension DataContext {
	enum KeychainKey: String {
		case authToken = "AUTH_TOKEN"
		case emailForLink = "EMAIL_FOR_LINK"

		var key: String {
			rawValue
		}
	}

	var authToken: String? {
		get {
			KeychainConfiguration.read(valueWithKey: KeychainKey.authToken.key)
		}
		set {
			guard let newValue = newValue else {
				KeychainConfiguration.delete(valueWithKey: KeychainKey.authToken.key)
				return
			}
			KeychainConfiguration.store(value: newValue, withKey: KeychainKey.authToken.key)
		}
	}

	var emailForLink: String? {
		get {
			KeychainConfiguration.read(valueWithKey: KeychainKey.emailForLink.key)
		}
		set {
			guard let newValue = newValue else {
				KeychainConfiguration.delete(valueWithKey: KeychainKey.emailForLink.key)
				return
			}
			KeychainConfiguration.store(value: newValue, withKey: KeychainKey.emailForLink.key)
		}
	}

	func clearKeychain() {
		KeychainConfiguration.logout()
	}
}
