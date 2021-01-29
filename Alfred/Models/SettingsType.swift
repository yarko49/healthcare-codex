//
//  SettingsModel.swift
//  Alfred
//

import Foundation

enum SettingsType: CustomStringConvertible, CaseIterable {
	case accountDetails
	case myDevices
	case notifications
	case systemAuthorization
	case feedback
	case privacyPolicy
	case termsOfService

	var description: String {
		switch self {
		case .accountDetails:
			return Str.accountDetails
		case .myDevices:
			return Str.myDevices
		case .notifications:
			return Str.notifications
		case .systemAuthorization:
			return Str.systemAuthorization
		case .feedback:
			return Str.feedback
		case .privacyPolicy:
			return Str.privacyPolicy
		case .termsOfService:
			return Str.termsOfService
		}
	}
}
