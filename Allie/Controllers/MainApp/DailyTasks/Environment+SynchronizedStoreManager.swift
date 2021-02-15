//
//  Environment+StoreManager.swift
//  Allie
//
//  Created by Waqar Malik on 11/19/20.
//

import CareKit
import Foundation
import SwiftUI

private struct SynchronizedStoreManagerEnvironmentKey: EnvironmentKey {
	static var defaultValue: OCKSynchronizedStoreManager {
		AppDelegate.appDelegate.carePlanStoreManager.synchronizedStoreManager
	}
}

extension EnvironmentValues {
	var synchronizedStoreManager: OCKSynchronizedStoreManager {
		get {
			self[SynchronizedStoreManagerEnvironmentKey.self]
		}
		set {
			self[SynchronizedStoreManagerEnvironmentKey.self] = newValue
		}
	}
}
