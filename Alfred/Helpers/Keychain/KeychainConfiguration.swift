import Foundation

enum KeychainConfiguration {
	static let serviceName = AppConfig.appBundleID
	static let accessGroup: String? = nil

	static func store(value: String, withKey key: String) {
		do {
			let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: key)
			try passwordItem.savePassword(value)
		} catch {
			ALog.error("Error updating keychain -", error: error)
		}
	}

	static func store(data: Data, withKey key: String) {
		do {
			let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: key)
			try passwordItem.saveData(data)
		} catch {
			ALog.error("Error updating keychain -", error: error)
		}
	}

	static func read(valueWithKey key: String) -> String? {
		do {
			let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: key, accessGroup: KeychainConfiguration.accessGroup)
			return try passwordItem.readPassword()
		} catch {
			ALog.error("Error reading password from keychain -", error: error)
			return nil
		}
	}

	static func read(dataWithKey key: String) -> Data? {
		do {
			let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: key, accessGroup: KeychainConfiguration.accessGroup)
			return try passwordItem.readData()
		} catch {
			ALog.error("Error reading data from keychain -", error: error)
			return nil
		}
	}

	static func delete(valueWithKey key: String) {
		do {
			let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: key, accessGroup: KeychainConfiguration.accessGroup)
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
