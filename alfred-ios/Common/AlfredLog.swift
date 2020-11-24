//
//  AlfredLog.swift
//  alfred-ios
//
//  Created by Waqar Malik on 11/19/20.
//

import Foundation
import os.log

private extension OSLog {
	private static var subsystem = Bundle.main.bundleIdentifier!

	static let alfred = OSLog(subsystem: subsystem, category: "Alfred")
}

internal enum AlfredLog {
	public static var level: OSLogType = .debug
}

internal func log(_ level: OSLogType = .info, _ message: StaticString, error: Error? = nil) {
	#if DEBUG
	guard level.rawValue >= AlfredLog.level.rawValue else {
		return
	}

	os_log(message, log: .alfred, type: level)

	if let error = error {
		os_log("Error: %{private}@", log: .alfred, type: level, error.localizedDescription)
	}
	#endif
}
