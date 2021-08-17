//
//  HealthKitManager+Injectable.swift
//  Allie
//
//  Created by Waqar Malik on 8/15/21.
//

import Foundation

private struct HealthKitManagerKey: InjectionKey {
	static var currentValue = HealthKitManager()
}

extension InjectedValues {
	var healthKitManager: HealthKitManager {
		get { Self[HealthKitManagerKey.self] }
		set { Self[HealthKitManagerKey.self] = newValue }
	}
}
