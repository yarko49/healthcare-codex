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

    init(timelineItemModel: TimelineItemModel) {
        self.timelineItemModel = timelineItemModel
    }

    // MARK: - Computed Properties
    var dateTime: Date {
        if let outcomeValue = timelineItemModel.outcomeValues?.first {
            return outcomeValue.createdDate
        }
        return self.getScheduledDateTime()
    }

    func hasOutcomeValue() -> Bool {
        if let outcomeValues = timelineItemModel.outcomeValues {
            return !outcomeValues.isEmpty
        } else {
            return false
        }
    }

    func getScheduledDateTime() -> Date {
        let date = Date()
        let min = Int.random(in: 0...120)
        let randomDate = Calendar.current.date(byAdding: .minute, value: min, to: date)
        return randomDate!
    }
}
