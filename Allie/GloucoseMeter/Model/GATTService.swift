//
//  GATTService.swift
//  Allie
//
//  Created by Waqar Malik on 8/25/21.
//

import Foundation

enum GATTService: Int {
	case deviceInformation = 0x180A
	case bloodPressure = 0x1810
	case bloodGlucose = 0x1808
	case heartRate = 0x180D
}

extension GATTService: BLEIdentifiable {}
