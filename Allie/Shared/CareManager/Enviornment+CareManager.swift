//
//  Enviornment+CareManager.swift
//  Allie
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

extension EnvironmentValues {
	var carePlanStoreManager: CareManager {
		get {
			self[CareManagerEnvironmentKey.self]
		}
		set {
			self[CareManagerEnvironmentKey.self] = newValue
		}
	}
}
