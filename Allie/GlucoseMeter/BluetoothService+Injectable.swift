//
//  BGMBluetoothManager+Injectable.swift
//  Allie
//
//  Created by Waqar Malik on 8/16/21.
//

import BluetoothService
import CodexFoundation
import Foundation

private struct BluetoothServiceKey: InjectionKey {
	static var currentValue = BluetoothService()
}

extension InjectedValues {
	var bluetoothService: BluetoothService {
		get { Self[BluetoothServiceKey.self] }
		set { Self[BluetoothServiceKey.self] = newValue }
	}
}
