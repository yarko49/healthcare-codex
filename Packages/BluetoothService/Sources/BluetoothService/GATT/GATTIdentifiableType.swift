//
//  GATTIdentifiableType.swift
//
//  Created by Waqar Malik on 12/9/21.
//

import CoreBluetooth
import Foundation

protocol GATTIdentifiableType: Identifiable, CustomStringConvertible, RawRepresentable, Hashable, CaseIterable {
	var uuid: CBUUID { get }
	var hexString: String { get }
}

extension GATTIdentifiableType {
	var id: CBUUID {
		uuid
	}

	var uuid: CBUUID {
		CBUUID(string: hexString)
	}

	var hexString: String {
		"0x" + description
	}
}

extension GATTIdentifiableType where RawValue == Int {
	var description: String {
		String(format: "%02x", rawValue)
	}
}
