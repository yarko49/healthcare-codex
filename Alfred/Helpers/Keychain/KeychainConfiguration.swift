import Foundation
import os.log

extension Logger {
	static let keychain = Logger(subsystem: subsystem, category: "Keychain")
}

enum Keychain {
	static let serviceName = AppConfig.appBundleID
	static let accessGroup: String? = nil

	static func store(value: String, withKey key: String) {
		do {
			let passwordItem = KeychainPasswordItem(service: Keychain.serviceName,
			                                        account: key)

			try passwordItem.savePassword(value)
		} catch {
			Logger.keychain.error("Error updating keychain - \(error.localizedDescription)")
		}
	}

	static func store(data: Data, withKey key: String) {
		do {
			let passwordItem = KeychainPasswordItem(service: Keychain.serviceName,
			                                        account: key)

			try passwordItem.saveData(data)
		} catch {
			Logger.keychain.error("Error updating keychain - \(error.localizedDescription)")
		}
	}

	static func read(valueWithKey key: String) -> String? {
		do {
			let passwordItem = KeychainPasswordItem(service: Keychain.serviceName,
			                                        account: key,
			                                        accessGroup: Keychain.accessGroup)
			return try passwordItem.readPassword()
		} catch {
			Logger.keychain.error("Error reading password from keychain - \(error.localizedDescription)")
			return nil
		}
	}

	static func read(dataWithKey key: String) -> Data? {
		do {
			let passwordItem = KeychainPasswordItem(service: Keychain.serviceName,
			                                        account: key,
			                                        accessGroup: Keychain.accessGroup)
			return try passwordItem.readData()
		} catch {
			Logger.keychain.error("Error reading data from keychain - \(error.localizedDescription)")
			return nil
		}
	}

	static func delete(valueWithKey key: String) {
		do {
			let passwordItem = KeychainPasswordItem(service: Keychain.serviceName,
			                                        account: key,
			                                        accessGroup: Keychain.accessGroup)
			try passwordItem.deleteItem()
		} catch {
			Logger.keychain.error("Error deleting password from keychain - \(error.localizedDescription)")
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
