//
//  CBCharacteristic+Convenience.swift
//
//
//  Created by Waqar Malik on 12/10/21.
//

import CoreBluetooth
import Foundation

public extension CBCharacteristic {
	func descriptor(uuid: CBUUID) -> CBDescriptor? {
		descriptors?.first(where: { descriptor in
			descriptor.uuid == uuid
		})
	}
}
