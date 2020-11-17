import Foundation

final class AppConfig {
	static var environmentName: String {
		return path("Environment", "Environment Name")!
	}

	static var appBundleID: String {
		return path("CFBundleIdentifier")!
	}

	static var apiBaseUrl: String {
		return path("Environment", "API Base URL")!
	}

	static var apiKey: String {
		return path("Environment", "API Key")!
	}

	static func path(_ keys: String...) -> String? {
		var current = Bundle.main.infoDictionary
		for (index, key) in keys.enumerated() {
			if index == keys.count - 1 {
				guard let
					result = (current?[key] as? String)?.replacingOccurrences(of: "\\", with: ""),
					result.count > 0 else
				{
					return nil
				}
				return result
			}
			current = current?[key] as? [String: Any]
		}
		return nil
	}
}
