import Foundation

final class AppConfig: ObservableObject {
	static var environmentName: String {
		path("Environment", "Environment Name")!
	}

	static var appBundleID: String {
		path("CFBundleIdentifier")!
	}

	static var apiBaseUrl: String {
		path("Environment", "API Base URL")!
	}

	static var apiKey: String {
		path("Environment", "API Key")!
	}

	static var tenantID: String {
		path("Environment", "Tenant ID")!
	}

	static var firebaseDeeplinkURL: String {
		path("Environment", "Firebase Deeplink URL")!
	}

    static var supportEmail: String {
        path("Environment", "Support Email")!
    }
    
	static func path(_ keys: String...) -> String? {
		var current = Bundle.main.infoDictionary
		for (index, key) in keys.enumerated() {
			if index == keys.count - 1 {
				guard let result = (current?[key] as? String)?.replacingOccurrences(of: "\\", with: ""), !result.isEmpty else {
					return nil
				}
				return result
			}
			current = current?[key] as? [String: Any]
		}
		return nil
	}
}
