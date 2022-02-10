//
//  AdvertisementInfo.swift
//
//
//  Created by Waqar Malik on 12/9/21.
//

import CoreBluetooth
import Foundation

public struct AdvertisementData {
	public let advertisementData: [String: Any]

	public init(advertisementData: [String: Any]) {
		self.advertisementData = advertisementData
	}

	public var localName: String? {
		advertisementData[CBAdvertisementDataLocalNameKey] as? String
	}

	public var manufacturerData: ManufacturerData? {
		guard let data = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data else {
			return nil
		}

		return ManufacturerData(data: data)
	}

	public var serviceData: [CBUUID: Data]? {
		advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data]
	}

	public var serviceUUIDs: [CBUUID]? {
		advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]
	}

	public var overflowServiceUUIDs: [CBUUID]? {
		advertisementData[CBAdvertisementDataOverflowServiceUUIDsKey] as? [CBUUID]
	}

	public var txPowerLevel: Double? {
		(advertisementData[CBAdvertisementDataTxPowerLevelKey] as? NSNumber)?.doubleValue
	}

	public var isConnectable: Bool? {
		advertisementData[CBAdvertisementDataIsConnectable] as? Bool
	}

	public var solicitedServiceUUIDs: [CBUUID]? {
		advertisementData[CBAdvertisementDataSolicitedServiceUUIDsKey] as? [CBUUID]
	}
}
