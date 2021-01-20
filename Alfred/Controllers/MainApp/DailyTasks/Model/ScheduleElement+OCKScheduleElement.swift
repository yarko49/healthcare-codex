//
//  OCKScheduleElement+ScheduleElement.swift
//  Alfred
//
//  Created by Waqar Malik on 1/2/21.
//

import CareKitStore
import Foundation

extension ScheduleElement {
	init(ockScheduleElement: OCKScheduleElement) {
		self.start = ockScheduleElement.start
		self.end = ockScheduleElement.end
		self.text = ockScheduleElement.text

		let interval = ockScheduleElement.interval
		self.hour = interval.hour ?? .zero
		self.minutes = interval.minute ?? .zero
		self.weekday = interval.weekday ?? .zero
		switch ockScheduleElement.duration {
		case .allDay:
			self.daily = true
			self.duration = 0
		case .seconds(let value):
			self.daily = false
			self.duration = value
		}
		self.interval = 0
		self.weekly = false
		self.custom = false
		self.targetValues = ockScheduleElement.targetValues.map { (value) -> OutcomeValue in
			OutcomeValue(ockOutcomeValue: value)
		}
	}

	var ockOutcomeValues: [OCKOutcomeValue] {
		targetValues?.map { (value) -> OCKOutcomeValue in
			OCKOutcomeValue(outcomeValue: value)
		} ?? []
	}

	var ockSchduleElement: OCKScheduleElement {
		OCKScheduleElement(scheduleElement: self)
	}

	var ockSchedule: OCKSchedule {
		OCKSchedule(composing: [ockSchduleElement])
	}
}

extension OCKScheduleElement {
	init(scheduleElement: ScheduleElement) {
		var components = DateComponents()
		components.hour = scheduleElement.hour
		components.minute = scheduleElement.minutes
		components.day = 1
		self.init(start: scheduleElement.start, end: scheduleElement.end, interval: components)
		self.text = scheduleElement.text ?? NSLocalizedString("ANYTIME", comment: "Anytime")
		self.duration = (scheduleElement.duration > 0) ? .seconds(scheduleElement.duration) : .allDay
		self.targetValues = scheduleElement.ockOutcomeValues
	}
}
