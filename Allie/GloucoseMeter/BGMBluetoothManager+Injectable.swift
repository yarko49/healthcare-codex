//
//  BGMBluetoothManager+Injectable.swift
//  Allie
//
//  Created by Waqar Malik on 8/16/21.
//

import Foundation

private struct BGMBluetoothManagerKey: InjectionKey {
	static var currentValue = BGMBluetoothManager()
}

extension InjectedValues {
	var bluetoothManager: BGMBluetoothManager {
		get { Self[BGMBluetoothManagerKey.self] }
		set { Self[BGMBluetoothManagerKey.self] = newValue }
	}
}
