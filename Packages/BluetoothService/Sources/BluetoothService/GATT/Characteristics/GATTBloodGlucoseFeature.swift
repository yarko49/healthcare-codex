//
//  GATTBloodGlucoseFeature.swift
//
//
//  Created by Waqar Malik on 2/3/22.
//

import CoreBluetooth
import Foundation

@frozen
public struct GATTBloodGlucoseFeature: GATTCharacteristic {
	public static var rawIdentifier: Int { 0x2A51 }

	internal static let length = MemoryLayout<UInt16>.size

	public let data: Data

	public init?(data: Data) {
		guard data.count >= type(of: self).length else {
			return nil
		}

		self.data = data
	}

	public var description: String {
		"Blood Glucose Feature"
	}
}
