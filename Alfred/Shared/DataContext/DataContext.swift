import Combine
import Foundation
import JGProgressHUD

class DataContext: ObservableObject {
	static let shared = DataContext()

	var hasSmartScale = false
	var hasSmartBlockPressureCuff = false
	var hasSmartWatch = false
	var hasSmartPedometer = false
	var updatePatient: UpdatePatientModels?

	@Published var resource: CodexResource? {
		willSet {
			objectWillChange.send()
		}
	}

	@Published var userModel: UserModel? {
		willSet {
			objectWillChange.send()
		}
	}

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
	var signUpCompleted = false
	var firstName: String?

	var getObservationData: CodexBundle?

	func clearAll() {
		clearKeychain()
		clearVariables()
	}

	func clearVariables() {
		hasSmartScale = false
		hasSmartBlockPressureCuff = false
		hasSmartWatch = false
		hasSmartPedometer = false
		activityPushNotificationsIsOn = false
		bloodPressurePushNotificationsIsOn = false
		weightInPushNotificationsIsOn = false
		surveyPushNotificationsIsOn = false
		weightGoal = 0.0
		bpGoal = 0.0
		stepsGoal = 0.0
		hrGoal = 0.0
		rhrGoal = 0.0
		userModel = nil
	}
}
