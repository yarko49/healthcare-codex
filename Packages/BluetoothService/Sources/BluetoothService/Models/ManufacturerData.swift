//
//  ManufacturerData.swift
//
//
//  Created by Waqar Malik on 12/9/21.
//

import Foundation

public struct ManufacturerData {
	public let data: Data

	public var companyIdentifier: UInt16 {
		let valueArray = [UInt8](data)
		var identifier = UInt16(valueArray[0]) << 8
		identifier = identifier | UInt16(valueArray[1])
		return identifier
	}

	public var companyIdentifierDescription: String? {
		CompanyIdentifier(rawValue: companyIdentifier)?.name
	}

	public var numberOfUsers: Int?
	public var isInPairingMode: Bool?
	public var isTimeNoConfigured: Bool?
	public var recordInfo: [RecordInfo]?

	public init(data: Data) {
		self.data = data
	}
}
