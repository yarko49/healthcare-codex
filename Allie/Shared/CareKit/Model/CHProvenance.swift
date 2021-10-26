//
//  CHProvenance.swift
//  Allie
//
//  Created by Waqar Malik on 9/4/21.
//

import Foundation

struct CHProvenance: Codable, Identifiable {
	var id: String
	var type: String
	var name: String?
	var address: String?
	var sequenceNumber: Int?
	var recordData: String?
	var contextData: String?
	var sampleType: String?
	var sampleLocation: String?

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
