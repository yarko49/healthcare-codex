//
//  Schedule.swift
//  Alfred
//
//  Created by Waqar Malik on 12/6/20.
//

import Foundation

public struct ScheduleElement: Codable, Hashable {
	public var start: Date
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

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let startDate = try container.decodeIfPresent(Date.self, forKey: .start) ?? Date()
		self.start = Calendar.current.startOfDay(for: startDate)
		self.end = try container.decodeIfPresent(Date.self, forKey: .end)
		self.weekly = try container.decodeIfPresent(Bool.self, forKey: .weekly) ?? false
		self.daily = try container.decodeIfPresent(Bool.self, forKey: .daily) ?? true
		self.interval = try container.decodeIfPresent(TimeInterval.self, forKey: .duration) ?? .zero
		self.custom = try container.decodeIfPresent(Bool.self, forKey: .custom) ?? false
		self.text = try container.decodeIfPresent(String.self, forKey: .text)
		self.targetValues = try container.decodeIfPresent([OutcomeValue].self, forKey: .targetValues)
		self.duration = try container.decodeIfPresent(TimeInterval.self, forKey: .duration) ?? .zero
		self.hour = try container.decodeIfPresent(Int.self, forKey: .hour) ?? .zero
		self.minutes = try container.decodeIfPresent(Int.self, forKey: .minutes) ?? .zero
		self.weekday = try container.decodeIfPresent(Int.self, forKey: .weekday) ?? .zero
	}
}
