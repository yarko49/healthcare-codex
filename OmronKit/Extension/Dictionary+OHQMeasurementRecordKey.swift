//
//  Dictionary+OHQMeasurementRecordKey.swift
//  OmronKit
//
//  Created by Waqar Malik on 1/27/22.
//

import Foundation

public extension Dictionary where Key == OHQMeasurementRecordKey, Value == Any {
	/// User Index (Type of value : NSNumber)
	var userIndex: Int {
		(self[.userIndexKey] as? NSNumber)?.intValue ?? 0
	}

	/// Time Stamp (Type of value : NSDate)
	var timeStamp: Date? {
		self[.timeStampKey] as? Date
	}

	/// Sequence Number (Type of value : NSNumber)
	var sequenceNumber: Int {
		(self[.sequenceNumberKey] as? NSNumber)?.intValue ?? 0
	}

	/// Blood Pressure Unit (Type of value : NSString, Unit is ["mmHg" or "kPa"])
	var bloodPressureUnit: String? {
		self[.bloodPressureUnitKey] as? String
	}

	/// Systolic Blood Pressure (Type of value : NSNumber)
	var systolic: Double? {
		(self[.systolicKey] as? NSNumber)?.doubleValue
	}

	/// Diastolic Blood Pressure (Type of value : NSNumber)
	var diastolic: Double? {
		(self[.diastolicKey] as? NSNumber)?.doubleValue
	}

	/// Mean Arterial Pressure (Type of value : NSNumber)
	var meanArterialPressure: Double? {
		(self[.meanArterialPressureKey] as? NSNumber)?.doubleValue
	}

	/// Pulse Rate (Type of value : NSNumber)
	var pulseRate: Int? {
		(self[.pulseRateKey] as? NSNumber)?.intValue
	}

	/// Blood Pressure Measurement status (Type of value : NSNumber)
	var bloodPressureMeasurementStatus: UInt16? {
		(self[.bloodPressureMeasurementStatusKey] as? NSNumber)?.uint16Value
	}

	/// Weight Unit (Type of value : NSString, Value is ["kg" or "lb"])
	var weightUnit: String? {
		self[.weightUnitKey] as? String
	}

	/// Weight (Type of value : NSNumber)
	var weight: Double? {
		(self[.weightKey] as? NSNumber)?.doubleValue
	}

	/// Height Unit (Type of value : NSString, Value is ["m" of "in"])
	var heightUnit: String? {
		self[.heightUnitKey] as? String
	}

	/// Height (Type of value : NSNumber)
	var height: Double? {
		(self[.heightKey] as? NSNumber)?.doubleValue
	}

	/// BMI (Type of value : NSNumber)
	var bmi: Double? {
		(self[.bmiKey] as? NSNumber)?.doubleValue
	}

	/// Body Fat Percentage (Type of value : NSNumber)
	var bodyFatPercentage: Double? {
		(self[.bodyFatPercentageKey] as? NSNumber)?.doubleValue
	}

	/// Basal Metabolism (Type of value : NSNumber, Unit is ["kJ"])
	var basalMetabolism: Double? {
		(self[.basalMetabolismKey] as? NSNumber)?.doubleValue
	}

	/// Muscle Percentage (Type of value : NSNumber)
	var musclePercentage: Double? {
		(self[.musclePercentageKey] as? NSNumber)?.doubleValue
	}

	/// Muscle Mass (Type of value : NSNumber, Unit is ["kg" or "lb"])
	var muscleMass: Double? {
		(self[.muscleMassKey] as? NSNumber)?.doubleValue
	}

	/// Fat Free Mass (Type of value : NSNumber, Unit is ["kg" or "lb"])
	var fatFreeMass: Double? {
		(self[.fatFreeMassKey] as? NSNumber)?.doubleValue
	}

	/// Soft Lean Mass (Type of value : NSNumber, Unit is ["kg" or "lb"])
	var softLeanMass: Double? {
		(self[.softLeanMassKey] as? NSNumber)?.doubleValue
	}

	/// Body Water Mass (Type of value : NSNumber, Unit is ["kg" or "lb"])
	var bodyWaterMass: Double? {
		(self[.bodyWaterMassKey] as? NSNumber)?.doubleValue
	}

	/// Impedance (Type of value : NSNumber, Unit is ["Ω"])
	var impedance: Double? {
		(self[.impedanceKey] as? NSNumber)?.doubleValue
	}

	/// Skeletal Muscle Percentage (Type of value : NSNumber)
	var skeletalMusclePercentage: Double? {
		(self[.skeletalMusclePercentageKey] as? NSNumber)?.doubleValue
	}

	/// Visceral Fat Level (Type of value : NSNumber)
	var visceralFatLevel: Double? {
		(self[.visceralFatLevelKey] as? NSNumber)?.doubleValue
	}

	/// Body Age (Type of value : NSNumber)
	var bodyAge: Double? {
		(self[.bodyAgeKey] as? NSNumber)?.doubleValue
	}

	/// Body Fat Percentage Stage Evaluation (Type of value : NSNumber)
	var bodyFatPercentageStageEvaluation: Double? {
		(self[.bodyFatPercentageStageEvaluationKey] as? NSNumber)?.doubleValue
	}

	/// Skeletal Muscle Percentage Stage Evaluation (Type of value : NSNumber)
	var skeletalMusclePercentageStageEvaluation: Double? {
		(self[.skeletalMusclePercentageStageEvaluationKey] as? NSNumber)?.doubleValue
	}

	/// Visceral Fat Level Stage Evaluation (Type of value : NSNumber)
	var visceralFatLevelStageEvaluation: Double? {
		(self[.visceralFatLevelStageEvaluationKey] as? NSNumber)?.doubleValue
	}
}
