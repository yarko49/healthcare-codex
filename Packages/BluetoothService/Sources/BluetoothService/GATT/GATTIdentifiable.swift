//
//  GATTIdentifiable.swift
//
//
//  Created by Waqar Malik on 2/6/22.
//

import CoreBluetooth
import Foundation

public protocol GATTIdentifiable {
	static var rawIdentifier: Int { get }
	static var uuid: CBUUID { get }

	static var hexString: String { get }
}

public extension GATTIdentifiable {
	static var hexString: String {
		String(format: "%02x", rawIdentifier)
	}

	static var uuid: CBUUID {
		CBUUID(string: hexString)
	}
}
