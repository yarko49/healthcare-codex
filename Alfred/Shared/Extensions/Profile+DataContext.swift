//
//  Profile+Create.swift
//  Alfred
//
//  Created by Waqar Malik on 1/26/21.
//

import Foundation
import HealthKit

extension Profile {
	init(dataContext: DataContext) {
		let device = HKDevice.local()
		let lastSyncTime = Date().byRemovingFractionalSeconds ?? Date()
		let dateNow = DateFormatter.wholeDateRequest.string(from: lastSyncTime)

		let bloodPressure = HealthMeasurements.Measuremement(notificationsEnabled: dataContext.bloodPressurePushNotificationsIsOn, available: dataContext.hasSmartBlockPressureCuff, goal: 0.0)
		let heartRate = HealthMeasurements.Measuremement(notificationsEnabled: dataContext.surveyPushNotificationsIsOn, available: dataContext.hasSmartWatch, goal: 0.0)
		let restingHR = HealthMeasurements.Measuremement(notificationsEnabled: dataContext.surveyPushNotificationsIsOn, available: dataContext.hasSmartWatch, goal: 0.0)
		let steps = HealthMeasurements.Measuremement(notificationsEnabled: dataContext.activityPushNotificationsIsOn, available: dataContext.hasSmartPedometer || dataContext.hasSmartWatch, goal: 0.0)
		let weight = HealthMeasurements.Measuremement(notificationsEnabled: dataContext.weightInPushNotificationsIsOn, available: dataContext.hasSmartScale, goal: 0.0)

		let healthMeasurements = HealthMeasurements(heartRate: heartRate, restingHeartRate: restingHR, steps: steps, weight: weight, bloodPressure: bloodPressure)

		let additionalProp1 = Devices.Device(model: device.model ?? "", version: device.firmwareVersion ?? "", id: device.udiDeviceIdentifier ?? "", lastSyncTime: dateNow, manufacturer: "Apple", name: "software", softwareVersion: device.softwareVersion ?? "")
		let devices = Devices(additionalProp1: additionalProp1, additionalProp2: Devices.Device(model: "", version: "", id: "", lastSyncTime: dateNow, manufacturer: "", name: "", softwareVersion: ""), additionalProp3: Devices.Device(model: "", version: "", id: "", lastSyncTime: dateNow, manufacturer: "", name: "", softwareVersion: ""))

		self.init(notificationsEnabled: true, registrationToken: "", healthMeasurements: healthMeasurements, devices: devices, signUpCompleted: dataContext.signUpCompleted)
	}
}
