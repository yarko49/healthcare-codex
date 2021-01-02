//
//  Logger+Setup.swift
//  Alfred
//
//  Created by Waqar Malik on 12/6/20.
//

import Foundation
import os.log

extension Logger {
	static var subsystem = Bundle.main.bundleIdentifier!
	static let alfred = Logger(subsystem: subsystem, category: "Alfred")
}
