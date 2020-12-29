//
//  Schedule.swift
//  Alfred
//
//  Created by Waqar Malik on 12/6/20.
//

import Foundation

public struct ScheduleElement: Codable, Hashable {
	public var start: Date?
	public var end: Date?
	public var weekly: Bool
	public var daily: Bool
	public var interval: TimeInterval // Seconds
	public var custom: Bool
	public var text: String?
	public var targetValues: [OutcomeValue]?
	public var duration: TimeInterval // Seconds
	public var hour: Int
	public var minutes: Int
	public var weekday: Int

	private enum CodingKeys: String, CodingKey {
		case start
		case end
		case weekly
		case daily
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
