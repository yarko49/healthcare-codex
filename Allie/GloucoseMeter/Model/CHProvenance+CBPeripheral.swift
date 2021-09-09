//
//  CHProvenance+CBPeripheral.swift
//  Allie
//
//  Created by Waqar Malik on 9/7/21.
//

import CoreBluetooth
import Foundation

extension CHProvenance {
	init?(peripheral: CBPeripheral?) {
		guard let peripheral = peripheral else {
			return nil
		}

		self.init(id: peripheral.identifier.uuidString, type: "bgm", name: peripheral.name, address: nil, sequenceNumber: nil, recordData: nil, contextData: nil, sampleType: nil, sampleLocation: nil)
	}
}
