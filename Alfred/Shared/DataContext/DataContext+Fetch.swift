import FirebaseAuth
import Foundation

extension DataContext {
	func searchPatient(user: User, completion: @escaping (Bool) -> Void) {
		showHUD()
		AlfredClient.client.postPatientSearch { [weak self] result in
			self?.hideHUD()
			switch result {
			case .success(let response):
				guard let resource = response.entry?.first?.resource else {
					completion(false)
					return
				}
				self?.resource = resource
				self?.userModel = UserModel(userID: resource.id, email: user.email, name: resource.name, dob: resource.birthDate, gender: Gender(rawValue: resource.gender ?? ""))
				completion(true)
			case .failure(let error):
				ALog.error("Patient Search", error: error)
				completion(false)
			}
		}
	}

	func getProfileAPI(completion: @escaping (Bool) -> Void) {
		showHUD()
		AlfredClient.client.getProfile { [weak self] result in
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
						self?.hasSmartBlockPressureCuff = (bloodPressure.available ?? false)
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

					self?.signUpCompleted = profile.signUpCompleted ?? false
					completion(true)
				}
			case .failure(let error):
				ALog.error("Get Profile", error: error)
				completion(false)
			}
		}
	}
}
