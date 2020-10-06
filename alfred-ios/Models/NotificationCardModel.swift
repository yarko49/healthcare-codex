//
//  NotificationCardModel.swift
//  alfred-ios
//

import Foundation

struct CardList: Codable {
    let notifications: [NotificationCard]
}

enum CardType: String, Codable {
    case coach = "COACH"
    case measurement = "MEASUREMENT"
}

enum IconType: String, Codable {
    case activity = "ACTIVITY"
    case heart = "HEART"
    case questionnaire = "QUESTIONNAIRE"
    case scale = "SCALE"
}

enum CardAction: String, Codable {
    case activity = "ACTIVITY"
    case bloodPressure = "BLOOD_PRESSURE"
    case weight = "WEIGHT"
    case questionnaire = "QUESTIONNAIRE"
}

struct NotificationCard: Codable {
    let name: String
    let data: NotificationCardData
}

struct NotificationCardData: Codable {
    let action: CardAction?
    let backgroundColor: String
    let expires: String
    let icon: IconType?
    let previewText: String?
    let previewTitle: String?
    let sampledTime: String?
    let status: String?
    let statusColor: String?
    let uuid: String
    let text: String?
    let title: String?
    let ttl: String
    let type: CardType
    let progressOpacity: Float?
    let progressPercent: Float?
    let progressColor: String?
}
