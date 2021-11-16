//
//  Schedule.swift
//  Allie
//
//  Created by Waqar Malik on 12/6/20.
//

import CareKitStore
import Foundation

struct CHScheduleElement: Codable {
	var start: Date // Start
	var end: Date? // End
	var weekly: Bool // Is it a weekly schedule
	var daily: Bool // is it a daily schedule
	var interval: TimeInterval // Seconds for custom
	var custom: Bool // is it a custom schedule
	var text: String?
	var targetValues: [OCKOutcomeValue]?
	var duration: TimeInterval // Seconds how long
	var hour: Int // Start hour
	var minutes: Int // Start minute
	var weekday: Int // if weekly then which day 0 index 0 == sunday

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

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let startDate = (try? container.decodeIfPresent(Date.self, forKey: .start)) ?? Date()
		self.start = Calendar.current.startOfDay(for: startDate)
		self.end = try container.decodeIfPresent(Date.self, forKey: .end)
		self.weekly = try container.decodeIfPresent(Bool.self, forKey: .weekly) ?? false
		self.daily = try container.decodeIfPresent(Bool.self, forKey: .daily) ?? true
		self.interval = try container.decodeIfPresent(TimeInterval.self, forKey: .duration) ?? .zero
		self.custom = try container.decodeIfPresent(Bool.self, forKey: .custom) ?? false
		self.text = try container.decodeIfPresent(String.self, forKey: .text)
		let targets = try container.decodeIfPresent([CHOutcomeValue].self, forKey: .targetValues)
		self.targetValues = targets?.map { value -> OCKOutcomeValue in
			OCKOutcomeValue(outcomeValue: value)
		}
		self.duration = try container.decodeIfPresent(TimeInterval.self, forKey: .duration) ?? .zero
		self.hour = try container.decodeIfPresent(Int.self, forKey: .hour) ?? .zero
		self.minutes = try container.decodeIfPresent(Int.self, forKey: .minutes) ?? .zero
		self.weekday = try container.decodeIfPresent(Int.self, forKey: .weekday) ?? .zero
		if minutes > 0 || hour > 0 {
			var updatedDate = Calendar.current.date(byAdding: .hour, value: hour, to: start)
			updatedDate = Calendar.current.date(byAdding: .minute, value: minutes, to: updatedDate ?? start)
			self.start = updatedDate ?? start
		}
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(start, forKey: .start)
		try container.encodeIfPresent(end, forKey: .end)
		try container.encode(weekly, forKey: .weekly)
		try container.encode(daily, forKey: .daily)
		try container.encode(interval, forKey: .interval)
		try container.encode(custom, forKey: .custom)
		try container.encodeIfPresent(text, forKey: .text)
		try container.encode(duration, forKey: .duration)
		try container.encode(hour, forKey: .hour)
		try container.encode(minutes, forKey: .minutes)
		try container.encode(weekday, forKey: .weekday)
		let values = targetValues?.map { outcome -> CHOutcomeValue in
			CHOutcomeValue(ockOutcomeValue: outcome)
		}
		try container.encodeIfPresent(values, forKey: .targetValues)
	}
}
