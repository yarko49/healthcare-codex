//
//  BGMCharacteristic.swift
//  Allie
//
//  Created by Waqar Malik on 8/16/21.
//

import CoreBluetooth
import Foundation

enum BGMCharacteristic: String, CaseIterable {
	case measurement = "0x2A18" // Actual Measurement
	case context = "0x2A34" // Context of the meaturement
	case feature = "0x2A51" // Features
	case racp = "0x2A52" // RecordAccessControlPoint

	var uuid: CBUUID {
		CBUUID(string: rawValue)
	}

	static var supportedCharacteristics: Set<CBUUID> {
		let supported: [BGMCharacteristic] = [.measurement, .context, .racp]
		return Set(supported.map { characteristic in
			characteristic.uuid
		})
	}
}
