//
//  UserDefaults+Settings.swift
//  Allie
//
//  Created by Waqar Malik on 1/26/21.
//

import Foundation

extension UserDefaults {
	subscript<T: Codable>(codable: String) -> T? {
		get {
			guard let data = data(forKey: codable) else {
				return nil
			}
			return try? JSONDecoder().decode(T.self, from: data)
		}
		set {
			guard let encodable = newValue else {
				removeObject(forKey: codable)
				return
			}
			let data = try? JSONEncoder().encode(encodable)
			setValue(data, forKey: codable)
		}
	}
}

extension UserDefaults {
	@UserDefault(key: "vectorClock", defaultValue: 0)
	static var vectorClock: UInt64

	@UserDefault(key: "measurementStepsNotificationEnabled", defaultValue: false)
	static var isMeasurementStepsNotificationEnabled: Bool

	@UserDefault(key: "measurementBloodPressureNotificationEnabled", defaultValue: false)
	static var isMeasurementBloodPressureNotificationEnabled: Bool

	@UserDefault(key: "measurementWeightNotificationEnabled", defaultValue: false)
	static var isMeasurementWeightNotificationEnabled: Bool

	@UserDefault(key: "measurementBloodGlucoseNotificationEnabled", defaultValue: false)
	static var isMeasurementBloodGlucoseNotificationEnabled: Bool

	@UserDefault(key: "lastObervationUploadDate", defaultValue: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date())
	static var lastObervationUploadDate: Date

	@UserDefault(key: "chatNotificationsCount", defaultValue: 0)
	static var chatNotificationsCount: Int

	@UserDefault(key: "zendeskChatNotificationCount", defaultValue: 0)
	static var zendeskChatNotificationCount: Int

	@UserDefault(key: "outcomeUploadDate", defaultValue: Date.distantPast)
	static var outcomeUploadDate: Date

	func resetUserDefaults() {
		let dictionary = dictionaryRepresentation()
		for (key, _) in dictionary {
			removeObject(forKey: key)
		}
	}

	subscript(outcomesUploadDate key: String) -> Date {
		get {
			value(forKey: key + "LastOutcomesUpload") as? Date ?? Date.distantPast
		}
		set {
			setValue(newValue, forKey: key + "LastOutcomesUpload")
		}
	}

	subscript(healthKitOutcomesUploadDate key: String) -> Date {
		get {
			let now = Date()
			return value(forKey: key + "LastOutcomesUpload") as? Date ?? Calendar.current.date(byAdding: .day, value: -14, to: now) ?? now
		}
		set {
			setValue(newValue, forKey: key + "LastOutcomesUpload")
		}
	}
}
