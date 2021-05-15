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
			return String.accountDetails
		case .myDevices:
			return String.myDevices
		case .notifications:
			return String.notifications
		case .systemAuthorization:
			return String.systemAuthorization
		case .feedback:
			return String.feedback
		case .troubleShoot:
			return String.troubleShoot
		case .support:
			return String.support
		case .privacyPolicy:
			return String.privacyPolicy
		case .termsOfService:
			return String.termsOfService
		}
	}

	var description: String {
		title
	}
}
