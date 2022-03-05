//
//  HKSample+OCKOutcomeValue.swift
//  Allie
//
//  Created by Waqar Malik on 5/25/21.
//

import CareKitStore
import Foundation
import HealthKit

public extension HKSample {
	func outcomeValues(task: OCKHealthKitTask) -> [OCKOutcomeValue] {
		let linkage = task.healthKitLinkage
		var values: [OCKOutcomeValue] = []
		if let cumulative = self as? HKCumulativeQuantitySample {
			if var value = OCKOutcomeValue(quantity: cumulative.sumQuantity, linkage: linkage) {
				value.kind = cumulative.quantityType.identifier
				if let insulinReason = cumulative.metadata?[HKMetadataKeyInsulinDeliveryReason] as? Int {
					value.kind = insulinReason == HKInsulinDeliveryReason.bolus.rawValue ? HKInsulinDeliveryReason.bolus.rawKind : HKInsulinDeliveryReason.basal.rawKind
				} else if let mealTimeValue = metadata?[CHMetadataKeyBloodGlucoseMealTime] as? Int ?? metadata?[HKMetadataKeyBloodGlucoseMealTime] as? Int, let mealTime = CHBloodGlucoseMealTime(rawValue: mealTimeValue) {
					value.kind = mealTime.kind
				}
				value.wasUserEntered = (cumulative.metadata?[HKMetadataKeyWasUserEntered] as? Bool) ?? false
				value.healthKitUUID = cumulative.uuid
				value.quantityIdentifier = linkage.quantityIdentifier.rawValue
				value.createdDate = cumulative.startDate
				values.append(value)
			}
		} else if let discreet = self as? HKDiscreteQuantitySample {
			let quantity = discreet.mostRecentQuantity
			if var value = OCKOutcomeValue(quantity: quantity, linkage: linkage) {
				value.kind = discreet.quantityType.identifier
				if let insulinReason = metadata?[HKMetadataKeyInsulinDeliveryReason] as? Int {
					value.kind = insulinReason == HKInsulinDeliveryReason.bolus.rawValue ? HKInsulinDeliveryReason.bolus.rawKind : HKInsulinDeliveryReason.basal.rawKind
				} else if let mealTimeValue = metadata?[CHMetadataKeyBloodGlucoseMealTime] as? Int ?? metadata?[HKMetadataKeyBloodGlucoseMealTime] as? Int, let mealTime = CHBloodGlucoseMealTime(rawValue: mealTimeValue) {
					value.kind = mealTime.kind
				}
				value.wasUserEntered = (discreet.metadata?[HKMetadataKeyWasUserEntered] as? Bool) ?? false
				value.healthKitUUID = discreet.uuid
				value.quantityIdentifier = linkage.quantityIdentifier.rawValue
				value.createdDate = discreet.startDate
				values.append(value)

				if let diastolicDoubleValue = metadata?[CHMetadataKeyBPDiastolicValue] as? Double, let startTimestamp = metadata?[CHOutcomeMetadataKeyStartDate] as? TimeInterval, let correlationSampleUuid = metadata?[CHMetadataKeyBPCorrelationSampleUUID] as? String {
					var diastolicValue = value
					diastolicValue.updateValue(newValue: Int(diastolicDoubleValue), newQuantityIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic.rawValue, newKind: HKQuantityTypeIdentifier.bloodPressureDiastolic.rawValue)
					value.updateValue(newValue: value.value, newQuantityIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic.rawValue, newKind: HKQuantityTypeIdentifier.bloodPressureSystolic.rawValue)
					diastolicValue.createdDate = Date(timeIntervalSince1970: startTimestamp)
					value.createdDate = Date(timeIntervalSince1970: startTimestamp)

					value.healthKitUUID = UUID(uuidString: correlationSampleUuid)
					diastolicValue.healthKitUUID = value.healthKitUUID

					values = [value, diastolicValue]
				}
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
					value.wasUserEntered = (sample.metadata?[HKMetadataKeyWasUserEntered] as? Bool) ?? false
					value.healthKitUUID = sample.uuid
					value.quantityIdentifier = linkage.quantityIdentifier.rawValue
					values.append(value)
				}
			}
		}
		return values
	}
}

public extension OCKOutcomeValue {
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
