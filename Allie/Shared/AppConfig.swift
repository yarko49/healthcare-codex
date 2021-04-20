import Foundation

enum AppConfig {
	static var environmentName: String {
		path("Environment", "Environment Name")!
	}

	static var appBundleID: String {
		path("CFBundleIdentifier")!
	}

	static var apiBaseHost: String {
		path("Environment", "API_Base_Host")!
	}

	static var apiVersion: String {
		path("Environment", "API_Version")!
	}

	static var apiBaseUrl: String {
		apiBaseHost + apiVersion
	}

	static var apiKey: String {
		path("Environment", "API_Key")!
	}

	static var tenantID: String {
		path("Environment", "Tenant_ID")!
	}

	static var firebaseDeeplinkURL: String {
		path("Environment", "Firebase_Deeplink_URL")!
	}

	static var supportEmail: String {
		path("Environment", "Support_Email")!
	}

	static var zendeskAppId: String {
		path("Environment", "Zendesk_App_Id")!
	}

	static var zendeskClientId: String {
		path("Environment", "Zendesk_Client_Id")!
	}

	static var zendeskURL: String {
		path("Environment", "Zendesk_URL")!
	}

	static var zendeskChatAccountKey: String {
		path("Environment", "Zendesk_Chat_Account_Key")!
	}

	static var zendeskChatAppId: String {
		path("Environment", "Zendesk_Chat_App_Id")!
	}

	static var keychainAccessGroup: String {
		"29P9H8TMND.com.codexhealth.Allie"
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
