//
//  CHTaskLinkType.swift
//  Ally
//
//  Created by Waqar Malik on 1/11/21.
//

import Foundation

enum CHTaskLinkType: String {
	case location = "linkLocation"
	case email = "linkEmail"
	case url = "linkURL"
	case website = "linkWebsite"
	case appStore = "linkAppStore"
	case call = "linkCall"
	case message = "linkMessage"

	var titleKey: String {
		rawValue + "Title"
	}

	var defaultTitle: String {
		switch self {
		case .appStore:
			return NSLocalizedString("APPSTORE", comment: "AppStore")
		case .call:
			return NSLocalizedString("CALL", comment: "Call")
		case .email:
			return NSLocalizedString("EMAIL", comment: "Email")
		case .location:
			return NSLocalizedString("ADDRESS", comment: "Address")
		case .message:
			return NSLocalizedString("MESSAGE", comment: "Message")
		case .url:
			return NSLocalizedString("URL", comment: "URL")
		case .website:
			return NSLocalizedString("WEBSITE", comment: "Website")
		}
	}
}
