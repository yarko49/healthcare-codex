//
//  Keychain+Injectable.swift
//  Allie
//
//  Created by Waqar Malik on 8/16/21.
//

import CodexFoundation
import Foundation
import KeychainAccess

private struct KeychainKey: InjectionKey {
	static var currentValue = Keychain(service: AppConfig.appBundleID)
}

extension InjectedValues {
	var keychain: Keychain {
		get { Self[KeychainKey.self] }
		set { Self[KeychainKey.self] = newValue }
	}
}
