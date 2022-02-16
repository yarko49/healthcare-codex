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

extension CHPeripheral: CustomStringConvertible {
	var description: String {
		"""
		{
		  id = \(id)
		  type = \(type)
		  localId = \(localId ?? "")
		  name = \(name)
		  info = \(info ?? "")
		  address = \(address ?? "")
		  lastSync = \(lastSync ?? "")
		  lastSyncDate = \(String(describing: lastSyncDate))
		}
		"""
	}
}
