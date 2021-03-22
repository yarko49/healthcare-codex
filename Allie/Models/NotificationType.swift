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
			return Str.activityPushNotifications
		case .bloodPressure:
			return Str.bloodPressurePushNotifications
		case .weightIn:
			return Str.weightInPushNotifications
		case .survey:
			return Str.surveyPushNotifications
		case .glucose:
			return NSLocalizedString("GLUCOSE_PUSH_NOTIFICATION", comment: "Glucose push notifications")
		}
	}

	var isEnabled: Bool {
		get {
			let careManager = AppDelegate.careManager
			switch self {
			case .activity:
				return careManager.patient?.isMeasurementStepsNotificationEnabled ?? false
			case .bloodPressure:
				return careManager.patient?.isMeasurementBloodPressureNotificationEnabled ?? false
			case .weightIn:
				return careManager.patient?.isMeasurementWeightNotificationEnabled ?? false
			case .survey:
				return false
			case .glucose:
				return careManager.patient?.isMeasurementBloodGlucoseNotificationEnabled ?? false
			}
		}
		set {
			let careManager = AppDelegate.careManager
			switch self {
			case .activity:
				careManager.patient?.isMeasurementStepsNotificationEnabled = newValue
			case .bloodPressure:
				careManager.patient?.isMeasurementBloodPressureNotificationEnabled = newValue
			case .weightIn:
				careManager.patient?.isMeasurementWeightNotificationEnabled = newValue
			case .survey:
				break
			case .glucose:
				careManager.patient?.isMeasurementBloodGlucoseNotificationEnabled = newValue
			}
		}
	}
}
