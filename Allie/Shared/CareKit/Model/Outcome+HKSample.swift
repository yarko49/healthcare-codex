//
//  Outcome+HKSample.swift
//  Allie
//
//  Created by Waqar Malik on 4/22/21.
//

import CareKitStore
import Foundation
import HealthKit

extension Outcome {
	init?(sample: HKSample, task: OCKHealthKitTask, carePlanId: String) {
		let linkage = task.healthKitLinkage
		var values: [OutcomeValue] = []
		if let cumulative = sample as? HKCumulativeQuantitySample {
			if var value = OutcomeValue(quantity: cumulative.sumQuantity, linkage: linkage) {
				value.kind = cumulative.quantityType.identifier
				if let insulinReason = cumulative.metadata?[HKMetadataKeyInsulinDeliveryReason] as? Int {
					value.kind = insulinReason == HKInsulinDeliveryReason.bolus.rawValue ? HKInsulinDeliveryReason.bolus.kind : HKInsulinDeliveryReason.basal.kind
				}
				value.createdDate = cumulative.startDate
				values.append(value)
			}
		} else if let discreet = sample as? HKDiscreteQuantitySample {
			let quantity = discreet.mostRecentQuantity
			if var value = OutcomeValue(quantity: quantity, linkage: linkage) {
				value.kind = discreet.quantityType.identifier
				value.index = 0
				if let insulinReason = sample.metadata?[HKMetadataKeyInsulinDeliveryReason] as? Int {
					value.kind = insulinReason == HKInsulinDeliveryReason.bolus.rawValue ? HKInsulinDeliveryReason.bolus.kind : HKInsulinDeliveryReason.basal.kind
				}
				value.createdDate = discreet.startDate
				values.append(value)
			}
		} else if let corrolation = sample as? HKCorrelation {
			let samples: [HKQuantitySample] = corrolation.objects.compactMap { sample in
				sample as? HKQuantitySample
			}
			var index: Int = 0
			for sample in samples {
				let quantity = sample.quantity
				if var value = OutcomeValue(quantity: quantity, linkage: linkage) {
					value.kind = sample.quantityType.identifier
					value.index = index
					value.createdDate = sample.startDate
					index += 1
					values.append(value)
				}
			}
		} else {
			return nil
		}
		guard !values.isEmpty else {
			return nil
		}

		self.init(taskUUID: task.uuid, taskID: task.id, carePlanID: carePlanId, taskOccurrenceIndex: 0, values: values)
		self.uuid = sample.uuid
		createdDate = sample.startDate
		updatedDate = sample.startDate
		effectiveDate = sample.startDate
		startDate = sample.startDate
		endDate = sample.endDate
		if let hkDevice = sample.device {
			device = CHDevice(device: hkDevice)
		}
		sourceRevision = CHSourceRevision(sourceRevision: sample.sourceRevision)
		userInfo = sample.metadata?.compactMapValues { anyValue in
			if let value = anyValue as? String {
				return value
			} else if let intValue = anyValue as? Int {
				return String(intValue)
			} else if let doubleValue = anyValue as? Double {
				return String(doubleValue)
			} else if let boolValue = anyValue as? Bool {
				return String(boolValue)
			} else if let date = anyValue as? Date {
				return Formatter.iso8601WithFractionalSeconds.string(from: date)
			} else {
				return nil
			}
		}
	}
}
