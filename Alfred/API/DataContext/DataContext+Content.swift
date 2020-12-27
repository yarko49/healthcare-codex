import Foundation
import HealthKit
import os.log

extension DataContext {
	func createProfileModel() -> ProfileModel {
		let device = HKDevice.local()
		let lastSyncTime = DataContext.shared.getDate() ?? Date()
		let dateNow = DateFormatter.wholeDateRequest.string(from: lastSyncTime)

		let bloodPressure = Measuremement(notificationsEnabled: DataContext.shared.bloodPressurePushNotificationsIsOn, available: DataContext.shared.hasSmartBlockPressureCuff, goal: 0.0)
		let heartRate = Measuremement(notificationsEnabled: DataContext.shared.surveyPushNotificationsIsOn, available: DataContext.shared.hasSmartWatch, goal: 0.0)
		let restingHR = Measuremement(notificationsEnabled: DataContext.shared.surveyPushNotificationsIsOn, available: DataContext.shared.hasSmartWatch, goal: 0.0)
		let steps = Measuremement(notificationsEnabled: DataContext.shared.activityPushNotificationsIsOn, available: DataContext.shared.hasSmartPedometer || DataContext.shared.hasSmartWatch, goal: 0.0)
		let weight = Measuremement(notificationsEnabled: DataContext.shared.weightInPushNotificationsIsOn, available: DataContext.shared.hasSmartScale, goal: 0.0)

		let healthMeasurements = HealthMeasurements(heartRate: heartRate, restingHeartRate: restingHR, steps: steps, weight: weight, bloodPressure: bloodPressure)

		let additionalProp1 = AdditionalProp(deviceModel: device.model ?? "", deviceVersion: device.firmwareVersion ?? "", id: device.udiDeviceIdentifier ?? "", lastSyncTime: dateNow, manufacturer: "Apple", softwareName: "software", softwareVersion: device.softwareVersion ?? "")
		let devices = Devices(additionalProp1: additionalProp1, additionalProp2: AdditionalProp(deviceModel: "", deviceVersion: "", id: "", lastSyncTime: dateNow, manufacturer: "", softwareName: "", softwareVersion: ""), additionalProp3: AdditionalProp(deviceModel: "", deviceVersion: "", id: "", lastSyncTime: dateNow, manufacturer: "", softwareName: "", softwareVersion: ""))

		let profile = ProfileModel(notificationsEnabled: true, registrationToken: "", healthMeasurements: healthMeasurements, devices: devices, signUpCompleted: signUpCompleted)

		return profile
	}
}
