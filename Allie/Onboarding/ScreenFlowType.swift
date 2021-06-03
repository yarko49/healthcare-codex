//
//  ScreenFlowType.swift
//  Allie
//
//  Created by Waqar Malik on 1/21/21.
//

import UIKit

enum ScreenFlowType: String, Hashable, CaseIterable, CustomStringConvertible {
	case welcome
	case welcomeSuccess
	case welcomeFailure
	case selectDevices
	case healthKit
	case activate // Not needed

	var description: String {
		rawValue
	}

	var image: UIImage? {
		switch self {
		case .welcome:
			return nil
		case .welcomeSuccess:
			return UIImage(named: "successIcon")
		case .welcomeFailure:
			return UIImage(systemName: "xmark.circle")
		case .selectDevices:
			return UIImage(named: "illustration7a")
		case .healthKit:
			return UIImage(named: "illustration8")
		case .activate:
			return UIImage(named: "illustration10")
		}
	}

	var viewTitle: String? {
		switch self {
		case .welcome:
			return String.welcome
		case .welcomeSuccess:
			return nil
		case .welcomeFailure:
			return nil
		case .selectDevices:
			return String.myDevices
		case .healthKit:
			return nil
		case .activate:
			return nil
		}
	}

	var title: String {
		switch self {
		case .welcome:
			return NSLocalizedString("AUTHORIZING", comment: "Authorizing...")
		case .welcomeSuccess:
			return String.successfulSignUp
		case .welcomeFailure:
			return String.signInFailed
		case .selectDevices:
			return String.appleHealthSelect
		case .healthKit:
			return String.appleHealthImport
		case .activate:
			return String.synced
		}
	}

	var subtitle: String {
		switch self {
		case .welcome:
			return ""
		case .welcomeSuccess:
			return String.continueProfile
		case .welcomeFailure:
			return ""
		case .selectDevices:
			return String.appleSelectMessage
		case .healthKit:
			return String.appleImportMessage
		case .activate:
			return ""
		}
	}

	var buttonTitle: String {
		switch self {
		case .welcome, .welcomeFailure, .welcomeSuccess, .selectDevices, .healthKit:
			return String.next.uppercased()
		case .activate:
			return String.done.uppercased()
		}
	}
}
