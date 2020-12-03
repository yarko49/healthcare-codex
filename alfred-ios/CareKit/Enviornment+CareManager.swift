//
//  Enviornment+CareManager.swift
//  alfred-ios
//
//  Created by Waqar Malik on 11/29/20.
//

import CareKit
import Foundation
import SwiftUI

private struct CareManagerEnvironmentKey: EnvironmentKey {
	static var defaultValue: CareManager {
		AppDelegate.appDelegate.careManager
	}
}

public extension EnvironmentValues {
	var careManager: CareManager {
		get {
			self[CareManagerEnvironmentKey.self]
		}
		set {
			self[CareManagerEnvironmentKey.self] = newValue
		}
	}
}
