//
//  GATTAppearance.swift
//
//
//  Created by Waqar Malik on 2/6/22.
//

import Foundation

@frozen
public struct GATTAppearance: GATTCharacteristic {
	public static var rawIdentifier: Int { 0x2A01 }

	public var data: Data

	public init?(data: Data) {
		self.data = data
	}

	public var description: String {
		"Appearance"
	}
}
