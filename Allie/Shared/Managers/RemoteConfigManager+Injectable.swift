//
//  RemoteConfigManager+Injectable.swift
//  Allie
//
//  Created by Waqar Malik on 10/12/21.
//

import Foundation

private struct RemoteConfigManagerKey: InjectionKey {
	static var currentValue = RemoteConfigManager()
}

extension InjectedValues {
	var remoteConfig: RemoteConfigManager {
		get { Self[RemoteConfigManagerKey.self] }
		set { Self[RemoteConfigManagerKey.self] = newValue }
	}
}
