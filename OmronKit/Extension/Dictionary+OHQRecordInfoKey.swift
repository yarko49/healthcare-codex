//
//  Dictionary+OHQRecordInfoKey.swift
//  Allie
//
//  Created by Waqar Malik on 1/27/22.
//

import Foundation

public extension Dictionary where Key == OHQRecordInfoKey, Value == Any {
	/// User Index (Type of value : NSNumber)
	var userIndex: Int {
		(self[.userIndexKey] as? NSNumber)?.intValue ?? 0
	}

	/// Sequence Number (Type of value : NSNumber)
	var lasSequenceNumber: Int {
		(self[.lastSequenceNumberKey] as? NSNumber)?.intValue ?? 0
	}

	/// Number of Records (Type of value : NSNumber)
	var numberOfRecords: Int {
		(self[.numberOfRecordsKey] as? NSNumber)?.intValue ?? 0
	}
}
