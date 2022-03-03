//
//  CHProvenance+CBPeripheral.swift
//  Allie
//
//  Created by Waqar Malik on 9/7/21.
//

import CareModel
import CoreBluetooth
import Foundation

extension CHProvenance {
	init?(peripheral: CBPeripheral?) {
		guard let peripheral = peripheral, let name = peripheral.name else {
			return nil
		}

		let type = name.contains("Contour") ? "bgm" : "other"
		self.init(id: name, type: type, name: peripheral.name, address: nil, sequenceNumber: nil, recordData: nil, contextData: nil, sampleType: nil, sampleLocation: nil)
	}
}
