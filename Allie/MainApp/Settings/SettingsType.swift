//
//  SettingsModel.swift
//  Allie
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
	case support
	case troubleShoot

	var title: String {
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
		case .troubleShoot:
			return Str.troubleShoot
		case .support:
			return Str.support
		case .privacyPolicy:
			return Str.privacyPolicy
		case .termsOfService:
			return Str.termsOfService
		}
	}

	var description: String {
		title
	}
}
