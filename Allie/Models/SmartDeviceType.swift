//  DevicesModel.swift
//  Allie
//

import Foundation

enum SmartDeviceType: String, CaseIterable, Hashable {
	case scale
	case bloodPressureCuff
	case watch
	case pedometer
	case bloodGlucoseMonitor

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
		case .bloodGlucoseMonitor:
			return NSLocalizedString("SMART_GLUCOSE_MONITOR", comment: "Gluocose Monitor")
		}
	}

	var hasSmartDevice: Bool {
		get {
			switch self {
			case .scale:
				return UserDefaults.standard.hasSmartScale
			case .bloodPressureCuff:
				return UserDefaults.standard.hasSmartBloodPressureCuff
			case .watch:
				return UserDefaults.standard.hasSmartWatch
			case .pedometer:
				return UserDefaults.standard.hasSmartPedometer
			case .bloodGlucoseMonitor:
				return UserDefaults.standard.hasSmartBloodGlucoseMonitor
			}
		}
		set {
			switch self {
			case .scale:
				UserDefaults.standard.hasSmartScale = newValue
			case .bloodPressureCuff:
				UserDefaults.standard.hasSmartBloodPressureCuff = newValue
			case .watch:
				UserDefaults.standard.hasSmartWatch = newValue
			case .pedometer:
				UserDefaults.standard.hasSmartPedometer = newValue
			case .bloodGlucoseMonitor:
				UserDefaults.standard.hasSmartBloodGlucoseMonitor = newValue
			}
		}
	}
}
