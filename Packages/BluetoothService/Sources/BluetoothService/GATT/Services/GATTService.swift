//
//  GATTService.swift
//
//  Created by Waqar Malik on 12/9/21.
//

import CoreBluetooth
import Foundation

public protocol GATTService: GATTIdentifiable, CustomStringConvertible {
	static var displayName: String { get }

	static var identifier: String { get }

	static var services: [CBUUID] { get }

	static var characteristics: [CBUUID] { get }
}

public extension GATTService {
	var description: String {
		Self.displayName
	}

	static var services: [CBUUID] { [] }

	static var characteristics: [CBUUID] { [] }
}
