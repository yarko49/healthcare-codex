//
//  SettingsModel.swift
//  Allie
//

import Foundation
import UIKit

enum SettingsType: CustomStringConvertible, CaseIterable, Hashable {
	case accountDetails
	case myDevices
	case notifications
	case systemAuthorization
	case feedback
	case privacyPolicy
	case termsOfService
	case support
	case troubleShoot
	case providers
	case logging

	var title: String {
		switch self {
		case .accountDetails:
			return String.accountDetails
		case .myDevices:
			return NSLocalizedString("CONNECTED_DEVICES", comment: "Connected Devices")
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
		case .providers:
			return NSLocalizedString("HEALTHCARE_PROVIDERS", comment: "Health Providers")
		case .logging:
			return "File Logging"
		}
	}

	var description: String {
		title
	}
}
