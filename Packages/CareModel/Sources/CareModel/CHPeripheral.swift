//
//  CHPeripheral.swift
//  Allie
//
//  Created by Waqar Malik on 1/12/22.
//

import CodexModel
import Foundation

public struct CHPeripheral: CMConnectableDevice, Codable {
	public var id: String
	public var type: String
	public var name: String
	public var localId: String?
	public var info: String?
	public var address: String?
	public var lastSync: String?
	public var lastSyncDate: Date?

	public init(id: String, type: String, name: String, localId: String? = nil, info: String? = nil, address: String? = nil, lastSync: String? = nil, lastSyncDate: Date? = nil) {
		self.id = id
		self.type = type
		self.localId = localId
		self.name = name
		self.info = info
		self.address = address
		self.lastSync = lastSync
		self.lastSyncDate = lastSyncDate
	}
}

extension CHPeripheral: CustomStringConvertible {
	public var description: String {
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
