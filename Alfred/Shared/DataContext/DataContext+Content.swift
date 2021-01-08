import Foundation
import HealthKit

extension DataContext {
	func createProfile() -> Profile {
		let device = HKDevice.local()
		let lastSyncTime = DataContext.shared.getDate() ?? Date()
		let dateNow = DateFormatter.wholeDateRequest.string(from: lastSyncTime)

		let bloodPressure = HealthMeasurements.Measuremement(notificationsEnabled: DataContext.shared.bloodPressurePushNotificationsIsOn, available: DataContext.shared.hasSmartBlockPressureCuff, goal: 0.0)
		let heartRate = HealthMeasurements.Measuremement(notificationsEnabled: DataContext.shared.surveyPushNotificationsIsOn, available: DataContext.shared.hasSmartWatch, goal: 0.0)
		let restingHR = HealthMeasurements.Measuremement(notificationsEnabled: DataContext.shared.surveyPushNotificationsIsOn, available: DataContext.shared.hasSmartWatch, goal: 0.0)
		let steps = HealthMeasurements.Measuremement(notificationsEnabled: DataContext.shared.activityPushNotificationsIsOn, available: DataContext.shared.hasSmartPedometer || DataContext.shared.hasSmartWatch, goal: 0.0)
		let weight = HealthMeasurements.Measuremement(notificationsEnabled: DataContext.shared.weightInPushNotificationsIsOn, available: DataContext.shared.hasSmartScale, goal: 0.0)

		let healthMeasurements = HealthMeasurements(heartRate: heartRate, restingHeartRate: restingHR, steps: steps, weight: weight, bloodPressure: bloodPressure)

		let additionalProp1 = Devices.Device(model: device.model ?? "", version: device.firmwareVersion ?? "", id: device.udiDeviceIdentifier ?? "", lastSyncTime: dateNow, manufacturer: "Apple", name: "software", softwareVersion: device.softwareVersion ?? "")
		let devices = Devices(additionalProp1: additionalProp1, additionalProp2: Devices.Device(model: "", version: "", id: "", lastSyncTime: dateNow, manufacturer: "", name: "", softwareVersion: ""), additionalProp3: Devices.Device(model: "", version: "", id: "", lastSyncTime: dateNow, manufacturer: "", name: "", softwareVersion: ""))

		let profile = Profile(notificationsEnabled: true, registrationToken: "", healthMeasurements: healthMeasurements, devices: devices, signUpCompleted: signUpCompleted)

		return profile
	}
}
