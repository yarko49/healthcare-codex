//
//  NotificationCardModel.swift
//  Allie
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
	case heartRate = "HEART_RATE"
	case heartRateResting = "HEART_RATE_RESTING"
	case other
}

extension IconType: UnknownCaseRepresentable {
	static let unknownCase: IconType = .other
}

enum CardAction: String, Codable {
	case activity = "ACTIVITY"
	case bloodPressure = "BLOOD_PRESSURE"
	case weight = "WEIGHT"
	case questionnaire = "QUESTIONNAIRE"
	case heartRate = "HEART_RATE"
	case heartRateResting = "HEART_RATE_RESTING"
	case other
}

extension CardAction: UnknownCaseRepresentable {
	static let unknownCase: CardAction = .other
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
