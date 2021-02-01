import Foundation

class Keychain {
	static let serviceName = AppConfig.appBundleID
	static let accessGroup: String? = nil

	class subscript(key: String) -> String? {
		get {
			Keychain.read(valueWithKey: key)
		}

		set {
			guard let value = newValue else {
				return
			}
			Keychain.store(value: value, withKey: key)
		}
	}

	class subscript(key: String) -> Data? {
		get {
			Keychain.read(dataWithKey: key)
		}

		set {
			guard let value = newValue else {
				return
			}
			Keychain.store(data: value, withKey: key)
		}
	}

	static func store(value: String, withKey key: String) {
		do {
			let passwordItem = KeychainPasswordItem(service: Keychain.serviceName, account: key)
			try passwordItem.savePassword(value)
		} catch {
			ALog.error("Error updating keychain -", error: error)
		}
	}

	static func store(data: Data, withKey key: String) {
		do {
			let passwordItem = KeychainPasswordItem(service: Keychain.serviceName, account: key)
			try passwordItem.saveData(data)
		} catch {
			ALog.error("Error updating keychain -", error: error)
		}
	}

	static func read(valueWithKey key: String) -> String? {
		do {
			let passwordItem = KeychainPasswordItem(service: Keychain.serviceName, account: key, accessGroup: Keychain.accessGroup)
			return try passwordItem.readPassword()
		} catch {
			ALog.error("Error reading password from keychain -", error: error)
			return nil
		}
	}

	static func read(dataWithKey key: String) -> Data? {
		do {
			let passwordItem = KeychainPasswordItem(service: Keychain.serviceName, account: key, accessGroup: Keychain.accessGroup)
			return try passwordItem.readData()
		} catch {
			ALog.error("Error reading data from keychain -", error: error)
			return nil
		}
	}

	static func delete(valueWithKey key: String) {
		do {
			let passwordItem = KeychainPasswordItem(service: Keychain.serviceName, account: key, accessGroup: Keychain.accessGroup)
			try passwordItem.deleteItem()
		} catch {
			ALog.error("Error deleting password from keychain -", error: error)
		}
	}

	static func logout() {
		let secItemClasses = [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity]
		for itemClass in secItemClasses {
			let spec: NSDictionary = [kSecClass: itemClass]
			SecItemDelete(spec)
		}
	}
}
