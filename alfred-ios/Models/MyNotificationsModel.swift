//
//  MyNotificationsModel.swift
//  alfred-ios
//

import Foundation

enum MyNotifications: CustomStringConvertible {
    case activityPushNotifications
    case bloodPressurePushNotifications
    case weightInPushNotifications
    case surveyPushNotifications
    case none
    
    var description : String {
        switch self {
        case .activityPushNotifications:
            return Str.activityPushNotifications
        case .bloodPressurePushNotifications:
            return Str.bloodPressurePushNotifications
        case .weightInPushNotifications:
            return Str.weightInPushNotifications
        case .surveyPushNotifications:
            return Str.surveyPushNotifications
        case .none:
            return ""
        }
    }
    
static let allValues = [activityPushNotifications, bloodPressurePushNotifications, weightInPushNotifications, surveyPushNotifications]
}
