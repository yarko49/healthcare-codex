//
//  TimelineItemViewModel.swift
//  Allie
//
//  Created by Onseen on 2/4/22.
//

import Foundation
import CareKitStore
import CareKit
import HealthKit
import CareKitUI

enum CellType: Int {
    case completed, current, future
}

struct TimelineItemModel {
    let id: String
    let outcomeValues: [OCKOutcomeValue]?
    let event: OCKAnyEvent

    init(outcomeValues: [OCKOutcomeValue]?, event: OCKAnyEvent) {
        id = UUID().uuidString
        self.outcomeValues = outcomeValues
        self.event = event
    }
}

class TimelineItemViewModel {

    var timelineItemModel: TimelineItemModel
    var tapCount: Int = 0
    var eventDate: Date = Date()
    var cellType: CellType = .completed
    var dateTime: Date = Date()

    init(timelineItemModel: TimelineItemModel, eventDate: Date) {
        self.timelineItemModel = timelineItemModel
        self.eventDate = eventDate
        setTempDateAndType()
    }

    // MARK: - Computed Properties

    func setTempDateAndType() {
        if let outcomeValue = timelineItemModel.outcomeValues?.first {
            cellType = .completed
            dateTime = outcomeValue.createdDate
            tapCount = 0
        } else {
            dateTime = self.getScheduledDateTime()
            if Calendar.current.isDateInToday(eventDate) {
                if Calendar.current.dateComponents([.minute], from: Date(), to: dateTime).minute! > 120 {
                    cellType = .future
                    tapCount = 0
                } else {
                    cellType = .current
                    tapCount = 1
                }
            } else {
                cellType = .current
                tapCount = 1
            }
        }
    }

    func hasOutcomeValue() -> Bool {
        if let outcomeValues = timelineItemModel.outcomeValues {
            return !outcomeValues.isEmpty
        } else {
            return false
        }
    }

    func getScheduledDateTime() -> Date {
        let min = Int.random(in: 0...200)
        let randomDate = Calendar.current.date(byAdding: .minute, value: min, to: eventDate)
        return randomDate!
    }
}
