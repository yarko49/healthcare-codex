//
//  Analytics+Allie.swift
//  Allie
//
//  Created by Waqar Malik on 2/21/21.
//

import FirebaseAnalytics
import Foundation

class AnalyticsManager {
	static var defaultProperties: [AnalyticsManager.PropertyKey: Any] = [:]
	enum EventType: String, CaseIterable, Hashable {
		case session
		case pageView
	}

	enum PropertyKey: String, CaseIterable, Hashable {
		case name
		case authFlowType
		case screenFlowType
	}

	static func send(event: AnalyticsManager.EventType, properties: [AnalyticsManager.PropertyKey: Any]?) {
		var allProperties: [String: Any] = [:]
		for (key, value) in defaultProperties {
			allProperties[key.rawValue] = value
		}
		if let properties = properties {
			for (key, value) in properties {
				allProperties[key.rawValue] = value
			}
		}
		Analytics.logEvent(event.rawValue, parameters: allProperties)
	}
}
