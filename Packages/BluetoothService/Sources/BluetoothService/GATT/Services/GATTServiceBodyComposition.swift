//
//  GATTServiceBodyComposition.swift
//
//
//  Created by Waqar Malik on 2/5/22.
//

import CoreBluetooth
import Foundation

@frozen
public struct GATTServiceBodyComposition: GATTService {
	public static var rawIdentifier: Int { 0x181B }

	public static var displayName: String {
		"Body Composition"
	}

	public static var identifier: String {
		"bodyComposition"
	}

	public init() {}
}
