//
//  Enviornment+CareManager.swift
//  Alfred
//
//  Created by Waqar Malik on 11/29/20.
//

import CareKit
import Foundation
import SwiftUI

private struct CarePlanStoreManagerEnvironmentKey: EnvironmentKey {
	static var defaultValue: CarePlanStoreManager {
		AppDelegate.appDelegate.carePlanStoreManager
	}
}

extension EnvironmentValues {
	var carePlanStoreManager: CarePlanStoreManager {
		get {
			self[CarePlanStoreManagerEnvironmentKey.self]
		}
		set {
			self[CarePlanStoreManagerEnvironmentKey.self] = newValue
		}
	}
}
