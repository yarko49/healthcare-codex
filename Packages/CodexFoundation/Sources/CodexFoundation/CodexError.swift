//
//  File.swift
//
//
//  Created by Waqar Malik on 2/12/22.
//

import Foundation

public enum CodexError: LocalizedError {
	case missing(String)
	case invalid(String)
	case compound([Error])
	case forbidden(String)

	public var errorDescription: String? {
		switch self {
		case .missing(let message):
			return "Data in missing \(message)"
		case .invalid(let message):
			return "Data is not in the correct format \(message)"
		case .compound:
			return "An array of errors"
		case .forbidden(let message):
			return "Forbidden \(message)"
		}
	}

	public var failureReason: String? {
		switch self {
		case .missing(let message):
			return message
		case .invalid(let message):
			return message
		case .compound:
			return "An array of errors"
		case .forbidden(let message):
			return message
		}
	}

	public var recoverySuggestion: String? {
		nil
	}

	public var helpAnchor: String? {
		nil
	}
}

extension CodexError: CustomNSError {
	public static var errorDomain: String {
		"com.codexhealth.CodexFoundation.Error"
	}

	public var errorCode: Int {
		switch self {
		case .missing:
			return 0
		case .invalid:
			return 1
		case .compound:
			return 2
		case .forbidden:
			return 3
		}
	}

	public var errorUserInfo: [String: Any] {
		var userInfo: [String: Any] = [:]
		if let description = errorDescription {
			userInfo[NSLocalizedDescriptionKey] = description
		}
		if let reason = failureReason {
			userInfo[NSLocalizedFailureReasonErrorKey] = reason
		}
		if let recovery = recoverySuggestion {
			userInfo[NSLocalizedRecoverySuggestionErrorKey] = recovery
		}
		if let help = helpAnchor {
			userInfo[NSLocalizedFailureErrorKey] = help
		}
		return userInfo
	}
}
