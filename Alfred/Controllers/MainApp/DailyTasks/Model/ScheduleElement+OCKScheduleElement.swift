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
		self.hour = interval.hour
		self.minutes = interval.minute
		self.weekday = interval.weekday
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

	var outcomeValues: [OCKOutcomeValue] {
		targetValues?.map { (value) -> OCKOutcomeValue in
			OCKOutcomeValue(outcomeValue: value)
		} ?? []
	}

	var ockSchduleElement: OCKScheduleElement {
		let startOfDay = Calendar.current.startOfDay(for: start ?? Date())
		let time = Calendar.current.date(byAdding: .hour, value: hour ?? 0, to: startOfDay)!
		return OCKScheduleElement(start: time, end: nil, interval: DateComponents(day: 1))
	}

	var ockSchedule: OCKSchedule {
		let durationTime = OCKScheduleElement.Duration.seconds(duration)
		return weekly ?
			OCKSchedule.weeklyAtTime(weekday: weekday ?? 0, hours: hour ?? 0, minutes: minutes ?? 0, start: start ?? Date(), end: end, targetValues: outcomeValues, text: text, duration: durationTime) :
			OCKSchedule.dailyAtTime(hour: hour ?? 0, minutes: minutes ?? 0, start: start ?? Date(), end: end, text: text, duration: durationTime, targetValues: outcomeValues)
	}
}

extension OCKScheduleElement {
	init(scheduleElement: ScheduleElement) {
		var components = DateComponents()
		components.hour = scheduleElement.hour
		components.minute = scheduleElement.minutes
		components.day = 0
		let startOfToday = Calendar.current.startOfDay(for: scheduleElement.start ?? Date())
		self.init(start: startOfToday, end: scheduleElement.end, interval: components)
		self.text = scheduleElement.text
		self.duration = scheduleElement.daily ? .allDay : .seconds(scheduleElement.duration)
		self.targetValues = scheduleElement.targetValues?.map { (value) -> OCKOutcomeValue in
			OCKOutcomeValue(outcomeValue: value)
		} ?? []
	}
}
