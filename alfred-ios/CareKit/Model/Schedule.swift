//
//  Schedule.swift
//  alfred-ios
//
//  Created by Waqar Malik on 12/6/20.
//

import Foundation

public struct Schedule: Codable, Hashable {
	public let startDate: Date
	public let endDate: Date
	public let isWeekly: Bool
	public let isDaily: Bool
	public let interval: TimeInterval
	public let custom: String
	public let text: String
	public let targetValues: [TargetValue]
	public let duration: Int
	public let hour: Int
	public let minutes: Int
	public let weekday: Int

	private enum CodingKeys: String, CodingKey {
		case startDate = "start"
		case endDate = "end"
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
