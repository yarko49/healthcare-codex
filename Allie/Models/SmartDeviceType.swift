//  DevicesModel.swift
//  Allie
//

import Foundation

enum SmartDeviceType: String, CaseIterable, Hashable {
	case scale
	case bloodPressureCuff
	case watch
	case pedometer

	var title: String {
		switch self {
		case .scale:
			return Str.smartScale
		case .bloodPressureCuff:
			return Str.smartBloodPressureCuff
		case .watch:
			return Str.smartWatch
		case .pedometer:
			return Str.smartPedometer
		}
	}
}
