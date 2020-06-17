import Foundation

struct Keychain {
    static let serviceName = AppConfig.appBundleID
    static let accessGroup: String? = nil
    
    static func store(value: String, withKey key: String) {
        do {
            let passwordItem = KeychainPasswordItem(service: Keychain.serviceName,
                                                    account: key)
            
            try passwordItem.savePassword(value)
        } catch {
            print("Error updating keychain - \(error)")
        }
    }
    
    static func store(data: Data , withKey key: String) {
        do {
            let passwordItem = KeychainPasswordItem(service: Keychain.serviceName,
                                                    account: key)
            
            try passwordItem.saveData(data)
        } catch {
            print("Error updating keychain - \(error)")
        }
    }
    
    static func read(valueWithKey key: String) -> String? {
        do {
            let passwordItem = KeychainPasswordItem(service: Keychain.serviceName,
                                                    account: key,
                                                    accessGroup: Keychain.accessGroup)
            return try passwordItem.readPassword()
        } catch {
            print("Error reading password from keychain - \(error)")
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
            print("Error reading data from keychain - \(error)")
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
            print("Error deleting password from keychain - \(error)")
        }
    }
    
    static func logout()  {
        let secItemClasses =  [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity]
        for itemClass in secItemClasses {
            let spec: NSDictionary = [kSecClass: itemClass]
            SecItemDelete(spec)
        }
    }
    
}
