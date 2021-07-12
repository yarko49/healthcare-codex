//
//  HKSample+OCKOutcomeValue.swift
//  Allie
//
//  Created by Waqar Malik on 5/25/21.
//

import CareKitStore
import Foundation
import HealthKit

extension HKSample {
	func outcomeValues(task: OCKHealthKitTask) -> [OCKOutcomeValue] {
		let linkage = task.healthKitLinkage
		var values: [OCKOutcomeValue] = []
		if let cumulative = self as? HKCumulativeQuantitySample {
			if var value = OCKOutcomeValue(quantity: cumulative.sumQuantity, linkage: linkage) {
				value.kind = cumulative.quantityType.identifier
				if let insulinReason = cumulative.metadata?[HKMetadataKeyInsulinDeliveryReason] as? Int {
					value.kind = insulinReason == HKInsulinDeliveryReason.bolus.rawValue ? HKInsulinDeliveryReason.bolus.kind : HKInsulinDeliveryReason.basal.kind
				} else if let mealTime = metadata?[HKMetadataKeyBloodGlucoseMealTime] as? Int {
					value.kind = mealTime == HKBloodGlucoseMealTime.preprandial.rawValue ? HKBloodGlucoseMealTime.preprandial.kind : HKBloodGlucoseMealTime.postprandial.kind
				}
				value.createdDate = cumulative.startDate
				values.append(value)
			}
		} else if let discreet = self as? HKDiscreteQuantitySample {
			let quantity = discreet.mostRecentQuantity
			if var value = OCKOutcomeValue(quantity: quantity, linkage: linkage) {
				value.kind = discreet.quantityType.identifier
				if let insulinReason = metadata?[HKMetadataKeyInsulinDeliveryReason] as? Int {
					value.kind = insulinReason == HKInsulinDeliveryReason.bolus.rawValue ? HKInsulinDeliveryReason.bolus.kind : HKInsulinDeliveryReason.basal.kind
				} else if let mealTime = metadata?[HKMetadataKeyBloodGlucoseMealTime] as? Int {
					value.kind = mealTime == HKBloodGlucoseMealTime.preprandial.rawValue ? HKBloodGlucoseMealTime.preprandial.kind : HKBloodGlucoseMealTime.postprandial.kind
				}
				value.createdDate = discreet.startDate
				values.append(value)
			}
		} else if let corrolation = self as? HKCorrelation {
			let samples: [HKQuantitySample] = corrolation.objects.compactMap { sample in
				sample as? HKQuantitySample
			}
			for sample in samples {
				let quantity = sample.quantity
				if var value = OCKOutcomeValue(quantity: quantity, linkage: linkage) {
					value.kind = sample.quantityType.identifier
					value.createdDate = sample.startDate
					values.append(value)
				}
			}
		}
		return values
	}
}

extension OCKOutcomeValue {
	init?(quantity: HKQuantity, linkage: OCKHealthKitLinkage) {
		if !quantity.is(compatibleWith: linkage.unit) {
			return nil
		}
		let doubleValue = quantity.doubleValue(for: linkage.unit)
		switch linkage.quantityIdentifier {
		case .bloodGlucose, .heartRate, .restingHeartRate, .bloodPressureSystolic, .bloodPressureDiastolic, .stepCount:
			self.init(Int(doubleValue), units: linkage.unit.unitString)
		default:
			self.init(doubleValue, units: linkage.unit.unitString)
		}
	}
}
