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

	var ockDuration: OCKScheduleElement.Duration {
		guard duration > 0 else {
			return .allDay
		}
		return .seconds(duration)
	}

	var ockSchedule: OCKSchedule {
		if weekly {
			return OCKSchedule.weeklyAtTime(weekday: weekday + 1, hours: hour, minutes: minutes, start: start, end: end, targetValues: ockOutcomeValues, text: text, duration: ockDuration)
		} else if daily {
			return OCKSchedule.dailyAtTime(hour: hour, minutes: minutes, start: start, end: end, text: text, duration: ockDuration, targetValues: ockOutcomeValues)
		} else {
			return OCKSchedule(composing: [ockSchduleElement])
		}
	}

	var displayText: String {
		text ?? NSLocalizedString("ANYTIME", comment: "Anytime")
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
		// let defaultDuration: OCKScheduleElement.Duration = scheduleElement.hour > 0 ? .hours(1) : .allDay
		let duration: OCKScheduleElement.Duration = (scheduleElement.duration > 0) ? .seconds(scheduleElement.duration) : .allDay
		self.init(start: startTime, end: scheduleElement.end, interval: interval, text: scheduleElement.displayText, targetValues: scheduleElement.ockOutcomeValues, duration: duration)
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
