
//  ProfileModel.swift
//  alfred-ios

import Foundation

// MARK: - Welcome
struct ProfileModel: Codable {
    let notificationsEnabled: Bool?
    let registrationToken: String?
    let healthMeasurements: HealthMeasurements?
    let devices: Devices?
    let signUpCompleted: Bool?
}

// MARK: - Devices
struct Devices: Codable {
    let additionalProp1, additionalProp2, additionalProp3: AdditionalProp?
}

// MARK: - AdditionalProp
struct AdditionalProp: Codable {
    let deviceModel, deviceVersion, id, lastSyncTime: String?
    let manufacturer, softwareName, softwareVersion: String?
}

// MARK: - HealthMeasurements
struct HealthMeasurements: Codable {
    let diastolicBloodPressure, heartRate, restingHeartRate, steps: DiastolicBloodPressure?
    let systolicBloodPressure, weight: DiastolicBloodPressure?
}

// MARK: - DiastolicBloodPressure
struct DiastolicBloodPressure: Codable {
    let notificationsEnabled, available: Bool?
}

// MARK: - Profile response

struct ProfileResponse: Codable {
    
}

