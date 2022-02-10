//
//  Dictionary+OHQManufacturerData.swift
//  Allie
//
//  Created by Waqar Malik on 1/27/22.
//

import Foundation

public extension Dictionary where Key == OHQManufacturerDataKey, Value == Any {
	/// Company Identifier (Type of value : NSNumber)
	var companyIdentifier: Int {
		(self[.companyIdentifierKey] as? NSNumber)?.intValue ?? 0
	}

	/// Company Identifier Description (Type of value : NSString)
	var identifierDescription: String? {
		self[.companyIdentifierDescriptionKey] as? String
	}

	/** Number of User (Type of value : NSNumber) */
	var numberOfUsers: Int {
		(self[.numberOfUserKey] as? NSNumber)?.intValue ?? 0
	}

	/// Is Pairing Mode (Type of value : NSNumber[BOOL]) */
	var isParingMode: Bool {
		(self[.isPairingMode] as? NSNumber)?.boolValue ?? false
	}

	/// Time Not Configured (Type of value : NSNumber[BOOL])
	var isTimeNotConfigured: Bool {
		(self[.timeNotConfigured] as? NSNumber)?.boolValue ?? false
	}

	/// Record Info Array (Type of value : NSArray<NSDictionary<OHQRecordInfoKey,id> *>)
	var recordInfo: [OHQRecordInfoKey: Any]? {
		self[.recordInfoArrayKey] as? [OHQRecordInfoKey: Any]
	}
}
