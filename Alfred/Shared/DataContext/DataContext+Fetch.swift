import FirebaseAuth
import Foundation
import os.log

extension DataContext {
	func fetchData(user: User, completion: @escaping (Bool) -> Void) {
		AlfredClient.client.postPatientSearch { [weak self] result in
			switch result {
			case .success(let response):
				guard let resource = response.entry?.first?.resource else {
					completion(false)
					return
				}
				self?.userModel = UserModel(userID: resource.id, email: user.email, name: resource.name, dob: resource.birthDate, gender: Gender(rawValue: resource.gender ?? ""))
				completion(true)
			case .failure(let error):
				os_log(.error, log: .alfred, "Patient Search %@", error.localizedDescription)
			}
		}
	}

	func getProfileAPI(completion: @escaping (Bool) -> Void) {
		AlfredClient.client.getProfile { [weak self] result in
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
				os_log(.error, log: .alfred, "Get Profile %@", error.localizedDescription)
				completion(false)
			}
		}
	}
}
