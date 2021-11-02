//
//  CHPatient.swift
//  Allie
//
//  Created by Waqar Malik on 12/6/20.
//

import CareKitStore
import UIKit
/*
 client ---push-patient-resource---> cloud-endpoint
                                          |
                                    FHIR ID Created
                                          |
 client <---pull-patient-resource--- cloud-endpoint
 */
typealias CHPatients = [CHPatient]

struct CHPatient: Codable, Identifiable, Equatable, OCKAnyPatient, AnyItemDeletable, AnyUserInfoExtensible {
	let id: String
	var uuid = UUID()
	var name: PersonNameComponents
	var sex: OCKBiologicalSex?
	var birthday: Date?
	var allergies: [String]?
	var createdDate: Date
	var effectiveDate: Date
	var updatedDate: Date?
	var deletedDate: Date?

	var groupIdentifier: String? // shared, active, inactive
	var tags: [String]?
	var remoteId: String?
	var source: String?
	var userInfo: [String: String]?
	var asset: String?
	var timezone: TimeZone
	var notes: [OCKNote]?
	var profile = CHProfile()

	var age: Int? {
		guard let birthday = birthday else {
			return nil
		}
		return Calendar.current.dateComponents(Set([.year]), from: birthday, to: Date()).year
	}

	var remoteID: String? {
		remoteId
	}

	struct CHProfile: Codable, Hashable {
		var email: String?
		var patientId: String?
		var userId: String?
		var phoneNumber: String?
		var deviceManufacturer: String?
		var deviceSoftwareVersion: String?
		var fhirId: String?
		var heightInInches: Int?
		var weightInPounds: Int?
		var isMeasurementBloodPressureEnabled: Bool = false
		var isMeasurementHeartRateEnabled: Bool = false
		var isMeasurementRestingHeartRateEnabled: Bool = false
		var isMeasurementStepsEnabled: Bool = false
		var isMeasurementWeightEnabled: Bool = false
		var areNotificationsEnabled: Bool = false
		var isSignUpCompleted: Bool = false

		var weightInKilograms: Double? {
			guard let lbs = weightInPounds else {
				return nil
			}

			return Double(lbs) * 0.4535924
		}

		var heightInCentimeters: Double? {
			guard let inches = heightInInches else {
				return nil
			}

			return Double(inches) * 2.54
		}

		var fhirUUID: UUID? {
			guard let fireIdString = fhirId else {
				return nil
			}
			return UUID(uuidString: fireIdString)
		}

		private enum CodingKeys: String, CodingKey {
			case email
			case patientId
			case userId
			case phoneNumber
			case deviceManufacturer
			case deviceSoftwareVersion
			case fhirId = "FHIRId"
			case heightInInches = "heightInches"
			case weightInPounds = "weightLbs"
			case isMeasurementBloodPressureEnabled = "measurementBloodPressureEnabled"
			case isMeasurementHeartRateEnabled = "measurementHeartRateEnabled"
			case isMeasurementRestingHeartRateEnabled = "measurementRestingHeartRateEnabled"
			case isMeasurementStepsEnabled = "measurementStepsEnabled"
			case isMeasurementWeightEnabled = "measurementWeightEnabled"
			case areNotificationsEnabled = "notificationsEnabled"
			case isSignUpCompleted = "signUpCompleted"
		}
	}

	init(id: String, name: PersonNameComponents) {
		self.id = id
		self.name = name
		self.timezone = TimeZone.current
		self.createdDate = Calendar.current.startOfDay(for: Date())
		self.effectiveDate = createdDate
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		self.id = try container.decode(String.self, forKey: .id)
		self.uuid = try container.decodeIfPresent(UUID.self, forKey: .uuid) ?? UUID()
		self.name = try container.decode(PersonNameComponents.self, forKey: .name)
		self.sex = try container.decodeIfPresent(OCKBiologicalSex.self, forKey: .sex)
		self.birthday = try container.decodeIfPresent(Date.self, forKey: .birthday)
		self.allergies = try container.decodeIfPresent([String].self, forKey: .allergies)
		self.createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate) ?? Calendar.current.startOfDay(for: Date())
		self.effectiveDate = try container.decodeIfPresent(Date.self, forKey: .effectiveDate) ?? createdDate
		self.updatedDate = try container.decodeIfPresent(Date.self, forKey: .updatedDate)
		self.deletedDate = try container.decodeIfPresent(Date.self, forKey: .deletedDate)
		self.groupIdentifier = try container.decodeIfPresent(String.self, forKey: .groupIdentifier)
		self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
		self.remoteId = try container.decodeIfPresent(String.self, forKey: .remoteId)
		if let value = remoteId, value.isEmpty {
			self.remoteId = nil
		}
		self.source = try container.decodeIfPresent(String.self, forKey: .source)
		if let value = source, value.isEmpty {
			self.source = nil
		}
		self.userInfo = try container.decodeIfPresent([String: String].self, forKey: .userInfo)
		self.asset = try container.decodeIfPresent(String.self, forKey: .asset)
		if let value = asset, value.isEmpty {
			self.asset = nil
		}
		self.timezone = (try? container.decode(TimeZone.self, forKey: .timezone)) ?? .current
		self.profile = try container.decodeIfPresent(CHProfile.self, forKey: .profile) ?? CHProfile()
		name.cleanup()
		if let fhirId = profile.fhirId, fhirId.isEmpty {
			profile.fhirId = nil
		}
		if profile.fhirId == nil, let id = userInfo?["FHIRId"] {
			profile.fhirId = id
		}
		if profile.weightInPounds == nil, let value = userInfo?["weightLbs"] {
			profile.weightInPounds = Int(value)
		}
		if profile.heightInInches == nil, let value = userInfo?["heightInches"] {
			profile.heightInInches = Int(value)
		}
		if profile.deviceManufacturer == nil {
			profile.deviceManufacturer = "Apple"
		}
		if profile.deviceSoftwareVersion == nil {
			profile.deviceSoftwareVersion = UIDevice.current.systemVersion
		}

		if remoteId == nil {
			self.remoteId = profile.userId ?? profile.patientId ?? profile.fhirId
		}
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encodeIfPresent(uuid, forKey: .uuid)
		try container.encode(name, forKey: .name)
		try container.encodeIfPresent(sex, forKey: .sex)
		try container.encodeIfPresent(birthday, forKey: .birthday)
		try container.encodeIfPresent(allergies, forKey: .allergies)
		try container.encodeIfPresent(createdDate, forKey: .createdDate)
		try container.encode(effectiveDate, forKey: .effectiveDate)
		try container.encodeIfPresent(updatedDate, forKey: .updatedDate)
		try container.encodeIfPresent(deletedDate, forKey: .deletedDate)
		try container.encodeIfPresent(groupIdentifier, forKey: .groupIdentifier)
		try container.encodeIfPresent(tags, forKey: .tags)
		try container.encodeIfPresent(remoteID, forKey: .remoteId)
		try container.encodeIfPresent(source, forKey: .source)
		try container.encodeIfPresent(userInfo, forKey: .userInfo)
		try container.encodeIfPresent(asset, forKey: .asset)
		try container.encode(timezone, forKey: .timezone)
		try container.encodeIfPresent(profile, forKey: .profile)
	}

	private enum CodingKeys: String, CodingKey {
		case id
		case uuid
		case name
		case sex
		case birthday
		case allergies
		case effectiveDate
		case createdDate
		case updatedDate
		case deletedDate
		case groupIdentifier
		case tags
		case remoteId
		case source
		case userInfo
		case profile
		case asset
		case notes
		case timezone
	}
}

extension CHPatient {
	var bgmIdentifier: String? {
		get {
			userInfo?["bgmIdentifier"]
		}
		set {
			setUserInfo(string: newValue, forKey: "bgmIdentifier")
		}
	}

	var bgmAddress: String? {
		get {
			userInfo?["bgmAddress"]
		}
		set {
			setUserInfo(string: newValue, forKey: "bgmAddress")
		}
	}

	var bgmLastSync: String? {
		get {
			userInfo?["bgmLastSync"]
		}
		set {
			setUserInfo(string: newValue, forKey: "bgmLastSync")
		}
	}

	var bgmLastSyncDate: String? {
		get {
			userInfo?["bgmLastSyncDate"]
		}
		set {
			setUserInfo(string: newValue, forKey: "bgmLastSyncDate")
		}
	}

	var bgmName: String? {
		get {
			userInfo?["bgmName"]
		}
		set {
			setUserInfo(string: newValue, forKey: "bgmName")
		}
	}
}

extension PersonNameComponents {
	mutating func cleanup() {
		if let value = namePrefix, value.isEmpty {
			namePrefix = nil
		}
		if let value = givenName, value.isEmpty {
			givenName = nil
		}

		if let value = middleName, value.isEmpty {
			middleName = nil
		}

		if let value = familyName, value.isEmpty {
			familyName = nil
		}

		if let value = nameSuffix, value.isEmpty {
			nameSuffix = nil
		}

		if let value = nickname, value.isEmpty {
			nickname = nil
		}
	}
}
