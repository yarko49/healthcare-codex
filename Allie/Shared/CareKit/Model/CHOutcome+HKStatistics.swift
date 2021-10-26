//
//  Outcome+HKStatistics.swift
//  Allie
//
//  Created by Waqar Malik on 5/19/21.
//

import CareKitStore
import Foundation
import HealthKit

extension CHOutcome {
	init?(statistics: HKStatistics, task: OCKHealthKitTask, carePlanId: String) {
		let linkage = task.healthKitLinkage
		let outcomes = statistics.sources?.compactMap { source -> CHOutcomeValue? in
			guard let quantity = statistics.sumQuantity(for: source) else {
				return nil
			}
			var value = CHOutcomeValue(quantity: quantity, linkage: linkage)
			value?.createdDate = statistics.startDate
			value?.kind = source.name
			return value
		}
		guard let values = outcomes, !values.isEmpty else {
			return nil
		}

		self.init(taskUUID: task.uuid, taskID: task.id, carePlanID: carePlanId, taskOccurrenceIndex: 0, values: values)
		self.uuid = UUID()
		createdDate = statistics.startDate
		updatedDate = statistics.startDate
		effectiveDate = task.effectiveDate
		startDate = statistics.startDate
		endDate = statistics.endDate
		setHealthKit(sampleUUID: UUID(), quantityIdentifier: linkage.quantityIdentifier)
	}
}
