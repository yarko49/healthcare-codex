//
//  BLEIdentifiable.swift
//  Allie
//
//  Created by Waqar Malik on 8/25/21.
//

import CoreBluetooth
import Foundation

protocol BLEIdentifiable: CustomStringConvertible, RawRepresentable, Hashable, CaseIterable {
	var uuid: CBUUID { get }
	var hexString: String { get }
}

extension BLEIdentifiable {
	var uuid: CBUUID {
		CBUUID(string: hexString)
	}

	var hexString: String {
		"0x" + description
	}
}

extension BLEIdentifiable where RawValue == Int {
	var description: String {
		String(format: "%02x", rawValue)
	}
}
