//
//  OCKScheduleElement+ScheduleElement.swift
//  Allie
//
//  Created by Waqar Malik on 1/2/21.
//

import CareKitStore
import Foundation

extension CHScheduleElement {
	var ockOutcomeValues: [OCKOutcomeValue] {
		targetValues ?? []
	}

	var ockSchduleElement: OCKScheduleElement {
		OCKScheduleElement(scheduleElement: self)
	}

	var ockSchedule: OCKSchedule {
		OCKSchedule(composing: [ockSchduleElement])
	}
}

extension OCKScheduleElement {
	init(scheduleElement: CHScheduleElement) {
		let interval = scheduleElement.weekly ? DateComponents(weekOfYear: 1) : DateComponents(day: 1)
		var startTime: Date
		if scheduleElement.weekly {
			startTime = Calendar.current.date(bySetting: .weekday, value: scheduleElement.weekday + 1, of: scheduleElement.start)!
			startTime = Calendar.current.date(bySettingHour: scheduleElement.hour, minute: scheduleElement.minutes, second: 0, of: startTime)!
		} else {
			startTime = Calendar.current.date(bySettingHour: scheduleElement.hour, minute: scheduleElement.minutes, second: 0, of: scheduleElement.start)!
		}
		let text = scheduleElement.text ?? NSLocalizedString("ANYTIME", comment: "Anytime")
		// let defaultDuration: OCKScheduleElement.Duration = scheduleElement.hour > 0 ? .hours(1) : .allDay
		let duration: OCKScheduleElement.Duration = (scheduleElement.duration > 0) ? .seconds(scheduleElement.duration) : .allDay
		self.init(start: startTime, end: scheduleElement.end, interval: interval, text: text, targetValues: scheduleElement.targetValues ?? [], duration: duration)
	}

	func merged(new: OCKScheduleElement) -> Self {
		var existing = self
		existing.end = new.end
		existing.duration = new.duration
		existing.interval = new.interval
		existing.targetValues = new.targetValues
		existing.text = new.text

		return existing
	}
}

extension OCKScheduleElement {
	static func dailyAtTime(hour: Int, minutes: Int, start: Date, end: Date?, text: String?, duration: OCKScheduleElement.Duration = .hours(1), targetValues: [OCKOutcomeValue] = []) -> OCKScheduleElement {
		let interval = DateComponents(day: 1)
		let startTime = Calendar.current.date(bySettingHour: hour, minute: minutes, second: 0, of: start)!
		let element = OCKScheduleElement(start: startTime, end: end, interval: interval, text: text, targetValues: targetValues, duration: duration)
		return element
	}

	// swiftlint:disable:next function_parameter_count
	static func weeklyAtTime(weekday: Int, hours: Int, minutes: Int, start: Date, end: Date?, targetValues: [OCKOutcomeValue], text: String?, duration: OCKScheduleElement.Duration = .hours(1)) -> OCKScheduleElement {
		let interval = DateComponents(weekOfYear: 1)
		var startTime = Calendar.current.date(bySetting: .weekday, value: weekday, of: start)!
		startTime = Calendar.current.date(bySettingHour: hours, minute: minutes, second: 0, of: startTime)!
		let element = OCKScheduleElement(start: startTime, end: end, interval: interval, text: text, targetValues: targetValues, duration: duration)
		return element
	}
}
