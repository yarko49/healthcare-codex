import Foundation

final class Languages {
	static func tr(_ key: String) -> String {
		let s = NSLocalizedString(key, bundle: LanguageManager.shared.getLocalBundle(), value: key, comment: "")
		return s
	}

	static func tr(_ key: String, _ args: [CVarArg]) -> String {
		let format = NSLocalizedString(key, bundle: LanguageManager.shared.getLocalBundle(), value: key, comment: "")
		return String(format: format, arguments: args)
	}
}
