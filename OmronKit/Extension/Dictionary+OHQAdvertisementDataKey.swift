//
//  Dictionary+OHQAdvertisementDataKey.swift
//  Allie
//
//  Created by Waqar Malik on 1/27/22.
//

import CoreBluetooth
import Foundation

public extension Dictionary where Key == OHQAdvertisementDataKey, Value == Any {
	/// Local Name (Type of value : String)
	var localName: String? {
		self[.localNameKey] as? String
	}

	/// Is Connectable (Type of value : NSNumber[BOOL])
	var isConnectable: Bool {
		(self[.isConnectable] as? NSNumber)?.boolValue ?? false
	}

	/// Service UUIDs (Type of value : NSArray<CBUUID *>)
	var serviceUUIDs: [CBUUID]? {
		self[.serviceUUIDsKey] as? [CBUUID]
	}

	/// Service Data (Type of value : NSDictionary<CBUUID *,NSData>)
	var serviceData: [CBUUID: Data]? {
		self[.serviceDataKey] as? [CBUUID: Data]
	}

	/// Overflow Service UUIDs (Type of value : NSArray<CBUUID *>)
	var overflowServiceUUIDs: [CBUUID]? {
		self[.overflowServiceUUIDsKey] as? [CBUUID]
	}

	/// Solicited Service UUIDs (Type of value : NSArray<CBUUID *>)
	var solicitedServiceUUIDs: [CBUUID]? {
		self[.solicitedServiceUUIDsKey] as? [CBUUID]
	}

	/// Tx Power Level (Type of value : NSNumber, Unit is ["dBm"])
	var txPowerLevel: Double? {
		(self[.txPowerLevelKey] as? NSNumber)?.doubleValue
	}

	/// Manufacturer Data (Type of value : NSDictionary<OHQManufacturerDataKey,id>)
	var manufacturerData: [OHQManufacturerDataKey: Any]? {
		self[.manufacturerDataKey] as? [OHQManufacturerDataKey: Any]
	}
}
