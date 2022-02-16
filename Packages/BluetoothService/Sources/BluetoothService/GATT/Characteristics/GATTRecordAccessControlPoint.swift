//
//  GATTRecordAccessControlPoint.swift
//
//
//  Created by Waqar Malik on 2/3/22.
//

import CoreBluetooth
import Foundation

@frozen
public struct GATTRecordAccessControlPoint: GATTCharacteristic {
	public static var rawIdentifier: Int { 0x2A52 }

	internal static let length = MemoryLayout<UInt8>.size

	public let data: Data

	public init?(data: Data) {
		self.data = data
	}

	public var description: String {
		"Record Access Control Point"
	}
}

public extension GATTRecordAccessControlPoint {
	static let allRecords: [UInt8] = [1, 1] // 1,1 get all records
	static let numberOfRecords: [UInt8] = [4, 1] // 4,1 get number of records
	static let lastRecord: [UInt8] = [1, 6] // 1,6 get last record received
	static let firstRecord: [UInt8] = [1, 5] // 1,5 get first record
	static let recordStart: [UInt8] = [1, 3, 1, 45, 0] // 1,3,1,45,0 extract from record 45 onwards

	static func recordStart(sequenceNumber: Int) -> [UInt8] {
		let sequence = sequenceNumber + 1 // sequenceNumber is the last glucose record that was written to HK
		let seqLowByte = UInt8(0xFF & sequence)
		let seqHighByte = UInt8(sequence >> 8)
		// os_log("Fetch data starting sequence #: %d", sequenceNumber)
		// [1, 3, 1, seqLowByte, seqHighByte]
		return [1, 3, 1, seqLowByte, seqHighByte]
	}
}
