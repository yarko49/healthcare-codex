//
//  CHPeripheral.swift
//  Allie
//
//  Created by Waqar Malik on 1/12/22.
//

import CodexModel
import Foundation

struct CHPeripheral: CMConnectableDevice, Codable {
	var id: String
	var type: String
	var localId: String?
	var name: String
	var info: String?
	var address: String?
	var lastSync: String?
	var lastSyncDate: Date?
}
