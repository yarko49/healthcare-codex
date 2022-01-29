//
//  Dictionary+OHQDeviceInfoKey.swift
//  Allie
//
//  Created by Waqar Malik on 1/27/22.
//

import Foundation

public extension Dictionary where Key == OHQDeviceInfoKey, Value == Any {
	/// Identifier (Type of value : NSUUID)
	var identifier: UUID {
		self[.identifierKey] as? UUID ?? UUID()
	}

	// Advertisement Data (Type of value : NSDictionary<OHQAdvertisementDataKey,id>)
	var advertisementData: [OHQAdvertisementDataKey: Any]? {
		self[.advertisementDataKey] as? [OHQAdvertisementDataKey: Any]
	}

	/// RSSI (Type of value : NSNumber, unit is in "dBm")
	var rssi: NSNumber? {
		self[.rssiKey] as? NSNumber
	}

	/// Model Name (Type of value : NSUUID)
	var modelName: UUID {
		self[.modelNameKey] as? UUID ?? UUID()
	}

	/// Category (Type of value : NSNumber[OHQDeviceCategory])
	var category: OHQDeviceCategory? {
		OHQDeviceCategory(rawValue: (self[.categoryKey] as? NSNumber)?.uintValue ?? .max)
	}
}
