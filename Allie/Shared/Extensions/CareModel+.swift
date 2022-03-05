//
//  CareModel+.swift
//  Allie
//
//  Created by Onseen on 3/5/22.
//

import CareKitUI
import CareModel
import Foundation

enum LinkSymbols {
	static let call = "phone.circle.fill"
	static let website = "safari.fill"
	static let email = "envelope.circle.fill"
	static let message = "message.circle.fill"
	static let appStore = "arrow.up.right.circle.fill"
	static let address = "location.circle.fill"
}

extension CHLink {
	var linkItemData: CareKitUI.LinkItem? {
		switch type {
		case .appStore:
			guard let value = appStore else {
				return nil
			}
			return LinkItem.appStore(id: value, title: title)
		case .call:
			guard let value = call else {
				return nil
			}
			return LinkItem.call(phoneNumber: value, title: title)
		case .email:
			guard let value = email else {
				return nil
			}
			return LinkItem.email(recipient: value, title: title)
		case .location:
			guard let lat = latitude, let long = longitude else {
				return nil
			}
			return LinkItem.location(lat, long, title: title)
		case .message:
			guard let value = message else {
				return nil
			}
			return LinkItem.message(phoneNumber: value, title: title)
		case .url:
			guard let value = url else {
				return nil
			}
			return LinkItem.url(value, title: title, symbol: symbol ?? "safari.fill")
		case .website:
			guard let value = website else {
				return nil
			}
			return LinkItem.website(value, title: title)
		}
	}
}

extension CHTask {
	var taskPriority: Int? {
		if let priority = userInfo?["priority"] {
			return Int(priority)
		} else {
			return nil
		}
	}
}

extension CareKitUI.LinkItem {
	var iconSymbol: String {
		switch self {
		case .url(_, _, let symbol): return symbol
		case .website: return LinkSymbols.website
		case .location: return LinkSymbols.address
		case .call: return LinkSymbols.call
		case .message: return LinkSymbols.message
		case .appStore: return LinkSymbols.appStore
		case .email: return LinkSymbols.email
		}
	}
}
