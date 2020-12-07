//
//  OSLog+Setup.swift
//  alfred-ios
//
//  Created by Waqar Malik on 12/6/20.
//

import Foundation
import os.log

extension OSLog {
	static let subsystem = Bundle.main.bundleIdentifier!
	static let alfred = OSLog(subsystem: subsystem, category: "Alfred")
}
