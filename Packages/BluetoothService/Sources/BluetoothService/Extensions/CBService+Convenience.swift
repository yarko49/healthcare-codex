//
//  CBService+Convenience.swift
//
//
//  Created by Waqar Malik on 12/10/21.
//

import CoreBluetooth
import Foundation

public extension CBService {
	func characteristic(uuid: CBUUID) -> CBCharacteristic? {
		characteristics?.first(where: { characteristic in
			characteristic.uuid == uuid
		})
	}
}
