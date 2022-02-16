//
//  File.swift
//
//
//  Created by Waqar Malik on 2/12/22.
//

import Foundation

public enum CodexError: Int, LocalizedError {
	case invalidData

	public var errorDescription: String? {
		switch self {
		case .invalidData:
			return "Data is not in the correct format"
		}
	}

	public var failureReason: String? {
		nil
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
		rawValue
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
