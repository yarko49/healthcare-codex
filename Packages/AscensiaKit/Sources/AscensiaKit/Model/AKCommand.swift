//
//  AKCommand.swift
//  Allie
//
//  Created by Waqar Malik on 8/26/21.
//

import Foundation
import os.log

public enum AKCommand {
	public static let allRecords: [UInt8] = [1, 1] // 1,1 get all records
	public static let numberOfRecords: [UInt8] = [4, 1] // 4,1 get number of records
	public static let lastRecord: [UInt8] = [1, 6] // 1,6 get last record received
	public static let firstRecord: [UInt8] = [1, 5] // 1,5 get first record
	public static let recordStart: [UInt8] = [1, 3, 1, 45, 0] // 1,3,1,45,0 extract from record 45 onwards

	public static func recordStart(sequenceNumber: Int) -> [UInt8] {
		let sequence = sequenceNumber + 1 // sequenceNumber is the last glucose record that was written to HK
		let seqLowByte = UInt8(0xFF & sequence)
		let seqHighByte = UInt8(sequence >> 8)
		// os_log("Fetch data starting sequence #: %d", sequenceNumber)
		// [1, 3, 1, seqLowByte, seqHighByte]
		return [1, 3, 1, seqLowByte, seqHighByte]
	}
}
