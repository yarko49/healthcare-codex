//
//  OHQDeviceDiscoveryInfo+Values.swift
//  Allie
//
//  Created by Waqar Malik on 1/27/22.
//

import Foundation

public extension OHQDeviceDiscoveryInfo {
	/// Local Name (Type of value : String)
	var localName: String? {
		advertisementData.localName
	}

	/// Is Connectable (Type of value : NSNumber[BOOL])
	var isConnectable: Bool {
		advertisementData.isConnectable
	}

	/// Service UUIDs (Type of value : NSArray<CBUUID *>)
	var serviceUUIDs: [CBUUID]? {
		advertisementData.serviceUUIDs
	}

	/// Service Data (Type of value : NSDictionary<CBUUID *,NSData>)
	var serviceData: [CBUUID: Data]? {
		advertisementData.serviceData
	}

	/// Overflow Service UUIDs (Type of value : NSArray<CBUUID *>)
	var overflowServiceUUIDs: [CBUUID]? {
		advertisementData.overflowServiceUUIDs
	}

	/// Solicited Service UUIDs (Type of value : NSArray<CBUUID *>)
	var solicitedServiceUUIDs: [CBUUID]? {
		advertisementData.solicitedServiceUUIDs
	}

	/// Tx Power Level (Type of value : NSNumber, Unit is ["dBm"])
	var txPowerLevel: Double? {
		advertisementData.txPowerLevel
	}

	/// Manufacturer Data (Type of value : NSDictionary<OHQManufacturerDataKey,id>)
	var manufacturerData: [OHQManufacturerDataKey: Any]? {
		advertisementData.manufacturerData
	}
}
