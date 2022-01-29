//
//  CMConnectableDevice.swift
//  Allie
//
//  Created by Waqar Malik on 12/14/21.
//

import Foundation

/**
 Remote or local connectable device
 - Parameter id: Unique identifier for the device
 - Parameter type; Type of device (Blood Pressure, Glucose, Weight,  etc etc)
 - Parameter localId: Local identifier if the platform provides (currently iOS provides UUID)
 - Parameter name: Name of the device, currently we use this for storing values for BGM
 - Parameter info: Description of the device
 - Parameter address: Mac Address of the device (iOS does not provides this, but android does)
 - Parameter last: Last sync
 - Parameter lastSyncDate: Date this device was last synced
 */
public protocol CMConnectableDevice: Identifiable, Hashable {
	var id: String { get set }
	var type: String { get set }
	var localId: String? { get set }
	var name: String { get set }
	var info: String? { get set }
	var address: String? { get set }
	var lastSync: String? { get set }
	var lastSyncDate: Date? { get set }
}
