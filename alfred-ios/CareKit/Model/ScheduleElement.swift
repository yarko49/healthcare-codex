//
//  Schedule.swift
//  alfred-ios
//
//  Created by Waqar Malik on 12/6/20.
//

import Foundation

public struct ScheduleElement: Codable {
	public let start: Date
	public let end: Date?
	public let isWeekly: Bool
	public let isDaily: Bool
	public let interval: TimeInterval
	public let custom: Bool
	public let text: String
	public let targetValues: [OutcomeValue]?
	public let duration: Int
	public let hour: Int
	public let minutes: Int
	public let weekday: Int

	private enum CodingKeys: String, CodingKey {
		case start
		case end
		case isWeekly = "weekly"
		case isDaily = "daily"
		case interval
		case custom
		case text
		case targetValues
		case duration
		case minutes
		case weekday
		case hour
	}
}
