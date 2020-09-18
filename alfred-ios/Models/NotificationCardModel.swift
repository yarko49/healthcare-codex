//
//  NotificationCardModel.swift
//  alfred-ios
//

import Foundation

struct CardList: Codable {
    let data: [NotificationCard]
}

enum CardType: String, Codable {
    case coach = "COACH"
    case measurement = "MEASUREMENT"
}

enum BackgroundColor: String, Codable {
    case blue = "BLUE"
    case orange = "ORANGE"
    case red = "RED"
    case green = "GREEN"
}

enum IconType: String, Codable {
    case activity = "ACTIVITY"
    case heart = "HEART"
    case questionnaire = "QUESTIONNAIRE"
    case scale = "SCALE"
}

enum StatusColor: String, Codable {
    case brown = "BROWN"
    case green = "GREEN"
    case red = "RED"
    case yellow = "YELLOW"
}

struct NotificationCard: Codable {
    
    let name: String
    let data: NotificationCardData
}

struct NotificationCardData: Codable {
    
    let backgroundColor: BackgroundColor
    let expires: String
    let icon: IconType
    let previewText: String?
    let previewTitle: String?
    let sampledTime: String?
    let status: String?
    let statusColor: StatusColor?
    let uuid: String
    let text: String
    let title: String
    let ttl: String
    let type: CardType
}
