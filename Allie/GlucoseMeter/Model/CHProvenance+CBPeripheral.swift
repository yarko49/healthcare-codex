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
		guard let peripheral = peripheral, let name = peripheral.name else {
			return nil
		}

		self.init(id: name, type: "bgm", name: peripheral.name, address: nil, sequenceNumber: nil, recordData: nil, contextData: nil, sampleType: nil, sampleLocation: nil)
	}
}
