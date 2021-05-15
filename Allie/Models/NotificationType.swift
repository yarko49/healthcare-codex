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
				return UserDefaults.standard.isMeasurementStepsNotificationEnabled
			case .bloodPressure:
				return UserDefaults.standard.isMeasurementBloodPressureNotificationEnabled
			case .weightIn:
				return UserDefaults.standard.isMeasurementWeightNotificationEnabled
			case .survey:
				return false
			case .glucose:
				return UserDefaults.standard.isMeasurementBloodGlucoseNotificationEnabled
			}
		}
		set {
			switch self {
			case .activity:
				UserDefaults.standard.isMeasurementStepsNotificationEnabled = newValue
			case .bloodPressure:
				UserDefaults.standard.isMeasurementBloodPressureNotificationEnabled = newValue
			case .weightIn:
				UserDefaults.standard.isMeasurementWeightNotificationEnabled = newValue
			case .survey:
				break
			case .glucose:
				UserDefaults.standard.isMeasurementBloodGlucoseNotificationEnabled = newValue
			}
		}
	}
}
