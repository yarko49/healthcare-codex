//
//  OCKTask+CareKitUI.swift
//  Allie
//
//  Created by Waqar Malik on 1/12/21.
//

import CareKitStore
import CareKitUI
import Foundation

extension String {
	func ch_suffix(byRemoving prefix: Self) -> Self {
		var result = self
		guard count > prefix.count else {
			return ""
		}
		result.removeFirst(prefix.count)
		return result
	}
}

extension OCKTask {
	var linkItems: [CareKitUI.LinkItem]? {
		let linkKeys = userInfo?.keys.filter { key -> Bool in
			key.hasPrefix("link") && !key.contains("Title")
		} ?? []

		guard !linkKeys.isEmpty else {
			return nil
		}

		let linkItems: [CareKitUI.LinkItem] = linkKeys.compactMap { key -> CareKitUI.LinkItem? in
			var taskLinktype: TaskLinkType = .appStore
			if key.hasPrefix(TaskLinkType.appStore.rawValue) {
				taskLinktype = .appStore
			} else if key.hasPrefix(TaskLinkType.call.rawValue) {
				taskLinktype = .call
			} else if key.hasPrefix(TaskLinkType.email.rawValue) {
				taskLinktype = .email
			} else if key.hasPrefix(TaskLinkType.location.rawValue) {
				taskLinktype = .location
			} else if key.hasPrefix(TaskLinkType.message.rawValue) {
				taskLinktype = .message
			} else if key.hasPrefix(TaskLinkType.url.rawValue) {
				taskLinktype = .url
			} else if key.hasPrefix(TaskLinkType.website.rawValue) {
				taskLinktype = .website
			}
			guard let value = userInfo?[key], !value.isEmpty else {
				return nil
			}
			let titleKey = taskLinktype.titleKey + key.ch_suffix(byRemoving: taskLinktype.rawValue)
			let title = userInfo?[titleKey]

			return taskLinktype.linkItem(value: value, title: title)
		}
		return linkItems
	}
}

extension TaskLinkType {
	func linkItem(value: String, title: String?) -> CareKitUI.LinkItem {
		let displayTitle = title ?? defaultTitle
		switch self {
		case .appStore:
			return LinkItem.appStore(id: value, title: displayTitle)
		case .call:
			return LinkItem.call(phoneNumber: value, title: displayTitle)
		case .email:
			return LinkItem.email(recipient: value, title: displayTitle)
		case .location:
			let latlong = value.components(separatedBy: ",") // "linkLocation": "37.4275,122.1697"
			return LinkItem.location(latlong[0], latlong[1], title: displayTitle)
		case .message:
			return LinkItem.message(phoneNumber: value, title: displayTitle)
		case .url:
			return LinkItem.website(value, title: displayTitle)
		case .website:
			return LinkItem.website(value, title: displayTitle)
		}
	}
}
