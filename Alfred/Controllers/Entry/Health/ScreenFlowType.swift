//
//  ScreenFlowType.swift
//  Alfred
//
//  Created by Waqar Malik on 1/21/21.
//

import UIKit

enum ScreenFlowType: Hashable, CaseIterable {
	case welcome
	case welcomeSuccess
	case welcomeFailure
	case selectDevices
	case healthKit
	case activate

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
			return Str.welcome
		case .welcomeSuccess:
			return nil
		case .welcomeFailure:
			return nil
		case .selectDevices:
			return Str.myDevices
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
			return Str.successfulSignUp
		case .welcomeFailure:
			return Str.signInFailed
		case .selectDevices:
			return Str.appleHealthSelect
		case .healthKit:
			return Str.appleHealthImport
		case .activate:
			return Str.synced
		}
	}

	var subtitle: String {
		switch self {
		case .welcome:
			return ""
		case .welcomeSuccess:
			return Str.continueProfile
		case .welcomeFailure:
			return ""
		case .selectDevices:
			return Str.appleSelectMessage
		case .healthKit:
			return Str.appleImportMessage
		case .activate:
			return ""
		}
	}

	var buttonTitle: String {
		switch self {
		case .welcome, .welcomeFailure, .welcomeSuccess, .selectDevices, .healthKit:
			return Str.next.uppercased()
		case .activate:
			return Str.done.uppercased()
		}
	}
}
