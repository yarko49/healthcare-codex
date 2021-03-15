import Combine
import Foundation
import JGProgressHUD
import ModelsR4

class DataContext: ObservableObject {
	static let shared = DataContext()

	var smartDevices: Set<SmartDeviceType> = []
	func hasSmartDevice(type: SmartDeviceType) -> Bool {
		smartDevices.contains(type)
	}

	var hasSmartScale: Bool {
		get {
			smartDevices.contains(.scale)
		}
		set {
			if newValue { smartDevices.insert(.scale) } else { smartDevices.remove(.scale) }
		}
	}

	var hasSmartBloodPressureCuff: Bool {
		get {
			smartDevices.contains(.bloodPressureCuff)
		}
		set {
			if newValue { smartDevices.insert(.bloodPressureCuff) } else { smartDevices.remove(.bloodPressureCuff) }
		}
	}

	var hasSmartWatch: Bool {
		get {
			smartDevices.contains(.watch)
		}
		set {
			if newValue { smartDevices.insert(.watch) } else { smartDevices.remove(.watch) }
		}
	}

	var hasSmartPedometer: Bool {
		get {
			smartDevices.contains(.pedometer)
		}
		set {
			if newValue { smartDevices.insert(.pedometer) } else { smartDevices.remove(.pedometer) }
		}
	}

	@Published var resource: ModelsR4.Patient?
	@Published var userModel: UserModel?

	private let hud: JGProgressHUD = {
		let view = JGProgressHUD(style: .dark)
		view.vibrancyEnabled = true
		return view
	}()

	func showHUD(animated: Bool = true) {
		hud.show(in: AppDelegate.primaryWindow, animated: true)
	}

	func hideHUD(animated: Bool = true) {
		hud.dismiss(animated: animated)
	}

	var dataModel: CodexBundle?
	var weightArray: [Int] = []
	var heightArray: [Int] = []

	var weightGoal = 0.0
	var bpGoal = 0.0
	var stepsGoal = 0.0
	var hrGoal = 0.0
	var rhrGoal = 0.0
	var activityPushNotificationsIsOn = false
	var bloodPressurePushNotificationsIsOn = false
	var weightInPushNotificationsIsOn = false
	var surveyPushNotificationsIsOn = false
	var getObservationData: CodexBundle?

	func clearAll() {
		Keychain.clearKeychain()
		clearVariables()
	}

	func clearVariables() {
		smartDevices.removeAll()
		activityPushNotificationsIsOn = false
		bloodPressurePushNotificationsIsOn = false
		weightInPushNotificationsIsOn = false
		surveyPushNotificationsIsOn = false
		weightGoal = 0.0
		bpGoal = 0.0
		stepsGoal = 0.0
		hrGoal = 0.0
		rhrGoal = 0.0
	}
}
