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
			Keychain.read(valueWithKey: KeychainKey.authToken.key)
		}
		set {
			guard let newValue = newValue else {
				Keychain.delete(valueWithKey: KeychainKey.authToken.key)
				return
			}
			Keychain.store(value: newValue, withKey: KeychainKey.authToken.key)
			remoteConfigManager.refresh()
		}
	}

	var emailForLink: String? {
		get {
			Keychain.read(valueWithKey: KeychainKey.emailForLink.key)
		}
		set {
			guard let newValue = newValue else {
				Keychain.delete(valueWithKey: KeychainKey.emailForLink.key)
				return
			}
			Keychain.store(value: newValue, withKey: KeychainKey.emailForLink.key)
		}
	}

	func clearKeychain() {
		Keychain.logout()
	}
}
