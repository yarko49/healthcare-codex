//
//  Environment+StoreManager.swift
//  Alfred
//
//  Created by Waqar Malik on 11/19/20.
//

import CareKit
import Foundation
import SwiftUI

private struct StoreManagerEnvironmentKey: EnvironmentKey {
	static var defaultValue: OCKSynchronizedStoreManager {
		AppDelegate.appDelegate.careManager.synchronizedStoreManager
	}
}

public extension EnvironmentValues {
	var storeManager: OCKSynchronizedStoreManager {
		get {
			self[StoreManagerEnvironmentKey.self]
		}
		set {
			self[StoreManagerEnvironmentKey.self] = newValue
		}
	}
}
