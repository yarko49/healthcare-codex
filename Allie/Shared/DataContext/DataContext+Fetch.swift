import CareKitStore
import FirebaseAuth
import Foundation

extension DataContext {
	func getProfileAPI(completion: @escaping (Bool) -> Void) {
		showHUD()
		APIClient.client.getProfile { [weak self] result in
			self?.hideHUD()
			switch result {
			case .success(let profile):
				if let healthMeasurements = profile.healthMeasurements {
					if let weight = healthMeasurements.weight {
						self?.hasSmartScale = weight.available ?? false
						self?.weightInPushNotificationsIsOn = weight.notificationsEnabled ?? false
						self?.weightGoal = weight.goal ?? 0.0
					}
					if let bloodPressure = healthMeasurements.bloodPressure {
						self?.hasSmartBloodPressureCuff = (bloodPressure.available ?? false)
						self?.bloodPressurePushNotificationsIsOn = bloodPressure.notificationsEnabled ?? false
						self?.bpGoal = bloodPressure.goal ?? 0.0
					}

					if let heartRate = healthMeasurements.heartRate, let restingHeartRate = healthMeasurements.restingHeartRate, let steps = healthMeasurements.steps {
						self?.hasSmartWatch = (heartRate.available ?? false) || (restingHeartRate.available ?? false) || (steps.available ?? false)
						self?.hasSmartPedometer = steps.available ?? false
						self?.activityPushNotificationsIsOn = steps.notificationsEnabled ?? false
						self?.surveyPushNotificationsIsOn = (heartRate.notificationsEnabled ?? false) || (restingHeartRate.notificationsEnabled ?? false)
						self?.stepsGoal = steps.goal ?? 0.0
						self?.hrGoal = heartRate.goal ?? 0.0
						self?.rhrGoal = restingHeartRate.goal ?? 0.0
					}

					AppDelegate.appCoordinator?.signUpCompleted = profile.signUpCompleted ?? false
					completion(true)
				}
			case .failure(let error):
				ALog.error("Get Profile", error: error)
				completion(false)
			}
		}
	}
}
