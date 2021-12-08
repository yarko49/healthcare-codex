//
//  NotificationType.swift
//  Allie
//
//  Created by Waqar Malik on 12/17/20.
//

import Foundation

enum NotificationType: String, CaseIterable, Hashable {
	case activity
	case bloodPressure
	case weightIn
	case survey
	case glucose

	var title: String {
		switch self {
		case .activity:
			return String.activityPushNotifications
		case .bloodPressure:
			return String.bloodPressurePushNotifications
		case .weightIn:
			return String.weightInPushNotifications
		case .survey:
			return String.surveyPushNotifications
		case .glucose:
			return NSLocalizedString("GLUCOSE_PUSH_NOTIFICATION", comment: "Glucose push notifications")
		}
	}

	var isEnabled: Bool {
		get {
			switch self {
			case .activity:
				return UserDefaults.isMeasurementStepsNotificationEnabled
			case .bloodPressure:
				return UserDefaults.isMeasurementBloodPressureNotificationEnabled
			case .weightIn:
				return UserDefaults.isMeasurementWeightNotificationEnabled
			case .survey:
				return false
			case .glucose:
				return UserDefaults.isMeasurementBloodGlucoseNotificationEnabled
			}
		}
		set {
			switch self {
			case .activity:
				UserDefaults.isMeasurementStepsNotificationEnabled = newValue
			case .bloodPressure:
				UserDefaults.isMeasurementBloodPressureNotificationEnabled = newValue
			case .weightIn:
				UserDefaults.isMeasurementWeightNotificationEnabled = newValue
			case .survey:
				break
			case .glucose:
				UserDefaults.isMeasurementBloodGlucoseNotificationEnabled = newValue
			}
		}
	}
}
