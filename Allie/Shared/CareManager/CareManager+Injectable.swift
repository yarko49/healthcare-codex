//
//  CareManager+Injectable.swift
//  Allie
//
//  Created by Waqar Malik on 8/15/21.
//

import CodexFoundation
import Foundation

private struct CareManagerKey: InjectionKey {
	static var currentValue = CareManager(patient: nil)
}

extension InjectedValues {
	var careManager: CareManager {
		get { Self[CareManagerKey.self] }
		set { Self[CareManagerKey.self] = newValue }
	}
}
