//
//  NotificationType.swift
//  Allie
//

import Foundation

enum NotificationType: String, CaseIterable, Hashable {
	case activity
	case bloodPressure
	case weightIn
	case survey

	var title: String {
		switch self {
		case .activity:
			return Str.activityPushNotifications
		case .bloodPressure:
			return Str.bloodPressurePushNotifications
		case .weightIn:
			return Str.weightInPushNotifications
		case .survey:
			return Str.surveyPushNotifications
		}
	}
}
