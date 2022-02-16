//
//  GATTBloodGlucoseMeasurementContext.swift
//
//
//  Created by Waqar Malik on 2/3/22.
//

import CoreBluetooth
import Foundation

@frozen
public struct GATTBloodGlucoseMeasurementContext: GATTCharacteristic {
	public static var rawIdentifier: Int { 0x2A34 }

	internal static let length = MemoryLayout<UInt16>.size

	public let data: Data

	public init?(data: Data) {
		guard data.count >= type(of: self).length else {
			return nil
		}

		self.data = data
	}

	public var description: String {
		"Blood Glucose Measurement Context"
	}

	public enum MealTime: Int, Hashable, CaseIterable {
		case unknown
		case preprandial
		case postprandial
		case fasting
		case casual
		case bedtime

		init?(kind: String) {
			let lower = kind.lowercased()
			if lower == "unknown" {
				self = .unknown
			} else if lower == "preprandial" {
				self = .preprandial
			} else if lower == "postprandial" {
				self = .postprandial
			} else if lower == "fasting" {
				self = .fasting
			} else if lower == "casual" {
				self = .casual
			} else if lower == "bedtime" {
				self = .bedtime
			} else {
				return nil
			}
		}
	}

	public enum SampleType: String, Hashable, CaseIterable {
		case capillaryWholeBlood
		case controlSolution
		case other

		public init(measurement: Int) {
			if measurement == 1 {
				self = .capillaryWholeBlood
			} else if measurement == 10 {
				self = .controlSolution
			} else {
				self = .other
			}
		}
	}
}

extension GATTBloodGlucoseMeasurementContext.MealTime: CustomStringConvertible {
	public var description: String {
		switch self {
		case .unknown:
			return "Unknown"
		case .preprandial:
			return "Preprandial"
		case .postprandial:
			return "Postprandial"
		case .fasting:
			return "Fasting"
		case .casual:
			return "Casual"
		case .bedtime:
			return "Bedtime"
		}
	}
}

public extension GATTBloodGlucoseMeasurementContext.MealTime {
	var kind: String {
		description.lowercased()
	}

	var title: String {
		switch self {
		case .unknown:
			return NSLocalizedString("MEAL_TIME_UNKNOWN", comment: "Unknown")
		case .preprandial:
			return NSLocalizedString("MEAL_TIME_BEFORE_MEAL", comment: "Before Meal")
		case .postprandial:
			return NSLocalizedString("MEAL_TIME_AFTER_MEAL", comment: "After Meal")
		case .fasting:
			return NSLocalizedString("MEAL_TIME_FASTING", comment: "Fasting")
		case .casual:
			return NSLocalizedString("MEAL_TIME_CASUAL", comment: "Casual")
		case .bedtime:
			return NSLocalizedString("MEAL_TIME_BEDTIME", comment: "Bedtime")
		}
	}

	var valueRange: ClosedRange<Int> {
		0 ... 999
	}
}

extension GATTBloodGlucoseMeasurementContext.SampleType: CustomStringConvertible {
	public var description: String {
		switch self {
		case .capillaryWholeBlood:
			return "Capillary Whole Blood"
		case .controlSolution:
			return "Control Solution"
		case .other:
			return"Other"
		}
	}
}
