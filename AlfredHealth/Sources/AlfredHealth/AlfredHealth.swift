//
//  AlfredHealth.swift
//  AlfredHealth
//
//  Created by Waqar Malik on 12/10/20.
//

import Foundation
import os.log

extension OSLog {
	static let subsystem = Bundle(for: RemoteSynchronizationManager.self).bundleIdentifier!
	static let health = OSLog(subsystem: subsystem, category: "AlfredHealth")
}
