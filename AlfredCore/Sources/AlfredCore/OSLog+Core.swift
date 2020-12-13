//
//  OSLog+Core.swift
//  AlfredCore
//
//  Created by Waqar Malik on 12/13/20.
//

import Foundation
import os.log

extension OSLog {
	static let subsystem = Bundle(for: WebService.self).bundleIdentifier!
}
