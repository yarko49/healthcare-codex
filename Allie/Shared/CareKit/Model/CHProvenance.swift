//
//  CHProvenance.swift
//  Allie
//
//  Created by Waqar Malik on 9/4/21.
//

import Foundation

public struct CHProvenance: Codable, Identifiable {
	public var id: String
	public var type: String
	public var name: String?
	public var address: String?
	public var sequenceNumber: Int?
	public var recordData: String?
	public var contextData: String?
	public var sampleType: String?
	public var sampleLocation: String?

	private enum CodingKeys: String, CodingKey {
		case id = "bgmDeviceId"
		case type
		case name = "bgmDeviceName"
		case address = "bgmDeviceAddress"
		case sequenceNumber = "bgmSequenceNumber"
		case recordData = "bgmGlucoseRecordData"
		case contextData = "bgmGlucoseContext"
		case sampleType = "bgmSampleType"
		case sampleLocation = "bgmSampleLocation"
	}
}

extension CHProvenance {
	static var manual: CHProvenance {
		CHProvenance(id: "", type: "manual", name: nil, address: nil, sequenceNumber: nil, recordData: nil, contextData: nil, sampleType: nil, sampleLocation: nil)
	}
}
