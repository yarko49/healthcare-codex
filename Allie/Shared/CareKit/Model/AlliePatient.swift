//
//  Patient.swift
//  Allie
//
//  Created by Waqar Malik on 12/6/20.
//

import CareKitStore
import Foundation

/*
 client ---push-patient-resource---> cloud-endpoint
                                          |
                                    FHIR ID Created
                                          |
 client <---pull-patient-resource--- cloud-endpoint
 */
public typealias AlliePatients = [AlliePatient]

public struct AlliePatient: Codable, Identifiable, OCKAnyPatient {
	public let id: String
	public var name: PersonNameComponents
	public var sex: OCKBiologicalSex?
	public var birthday: Date?
	public var allergies: [String]?

	public var effectiveDate: Date
	public var createdDate: Date?
	public var updatedDate: Date?

	public var groupIdentifier: String? // shared, active, inactive
	public var tags: [String]?
	public var remoteID: String?
	public var source: String?
	public var userInfo: UserInfo?
	public var asset: String?
	public var timezone: TimeZone
	public var notes: [OCKNote]?

	public struct UserInfo: Codable {
		public var deviceManufacturer: String?
		public var deviceSoftwareVersion: String?
		public var fhirId: String?
		public var isMeasurementBloodPressureEnabled: Bool
		public var isMeasurementHeartRateEnabled: Bool
		public var isMeasurementRestingHeartRateEnabled: Bool
		public var isMeasurementStepsEnabled: Bool
		public var isMeasurementWeightEnabled: Bool
		public var areNotificationsEnabled: Bool
		public var isSignUpCompleted: Bool

		private enum CodingKeys: String, CodingKey {
			case deviceManufacturer
			case deviceSoftwareVersion
			case fhirId = "FHIRId"
			case isMeasurementBloodPressureEnabled = "measurementBloodPressureEnabled"
			case isMeasurementHeartRateEnabled = "measurementHeartRateEnabled"
			case isMeasurementRestingHeartRateEnabled = "measurementRestingHeartRateEnabled"
			case isMeasurementStepsEnabled = "measurementStepsEnabled"
			case isMeasurementWeightEnabled = "measurementWeightEnabled"
			case areNotificationsEnabled = "notificationsEnabled"
			case isSignUpCompleted = "signUpCompleted"
		}

		init(values: [String: String]) {
			self.deviceManufacturer = values[CodingKeys.deviceManufacturer.rawValue]
			self.deviceSoftwareVersion = values[CodingKeys.deviceSoftwareVersion.rawValue]
			self.fhirId = values[CodingKeys.fhirId.rawValue]
			self.isMeasurementBloodPressureEnabled = Bool(values[CodingKeys.isMeasurementBloodPressureEnabled.rawValue] ?? "") ?? false
			self.isMeasurementHeartRateEnabled = Bool(values[CodingKeys.isMeasurementHeartRateEnabled.rawValue] ?? "") ?? false
			self.isMeasurementRestingHeartRateEnabled = Bool(values[CodingKeys.isMeasurementRestingHeartRateEnabled.rawValue] ?? "") ?? false
			self.isMeasurementStepsEnabled = Bool(values[CodingKeys.isMeasurementStepsEnabled.rawValue] ?? "") ?? false
			self.isMeasurementWeightEnabled = Bool(values[CodingKeys.isMeasurementWeightEnabled.rawValue] ?? "") ?? false
			self.areNotificationsEnabled = Bool(values[CodingKeys.areNotificationsEnabled.rawValue] ?? "") ?? false
			self.isSignUpCompleted = Bool(values[CodingKeys.isSignUpCompleted.rawValue] ?? "") ?? false
		}

		public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			self.deviceManufacturer = try container.decodeIfPresent(String.self, forKey: .deviceManufacturer)
			self.deviceSoftwareVersion = try container.decodeIfPresent(String.self, forKey: .deviceSoftwareVersion)
			self.fhirId = try container.decodeIfPresent(String.self, forKey: .fhirId)
			self.isMeasurementBloodPressureEnabled = try container.decodeIfPresent(Bool.self, forKey: .isMeasurementBloodPressureEnabled) ?? false
			self.isMeasurementHeartRateEnabled = try container.decodeIfPresent(Bool.self, forKey: .isMeasurementHeartRateEnabled) ?? false
			self.isMeasurementRestingHeartRateEnabled = try container.decodeIfPresent(Bool.self, forKey: .isMeasurementRestingHeartRateEnabled) ?? false
			self.isMeasurementStepsEnabled = try container.decodeIfPresent(Bool.self, forKey: .isMeasurementStepsEnabled) ?? false
			self.isMeasurementWeightEnabled = try container.decodeIfPresent(Bool.self, forKey: .isMeasurementWeightEnabled) ?? false
			self.areNotificationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .areNotificationsEnabled) ?? false
			self.isSignUpCompleted = try container.decodeIfPresent(Bool.self, forKey: .isSignUpCompleted) ?? false
		}

		var userInfo: [String: String]? {
			var info: [String: String] = [:]
			if let value = deviceManufacturer {
				info[CodingKeys.deviceManufacturer.rawValue] = value
			}

			if let value = deviceSoftwareVersion {
				info[CodingKeys.deviceSoftwareVersion.rawValue] = value
			}

			if let value = fhirId {
				info[CodingKeys.fhirId.rawValue] = value
			}

			info[CodingKeys.isMeasurementBloodPressureEnabled.rawValue] = String(isMeasurementBloodPressureEnabled)
			info[CodingKeys.isMeasurementHeartRateEnabled.rawValue] = String(isMeasurementHeartRateEnabled)
			info[CodingKeys.isMeasurementRestingHeartRateEnabled.rawValue] = String(isMeasurementRestingHeartRateEnabled)
			info[CodingKeys.isMeasurementStepsEnabled.rawValue] = String(isMeasurementStepsEnabled)
			info[CodingKeys.isMeasurementWeightEnabled.rawValue] = String(isMeasurementWeightEnabled)
			info[CodingKeys.areNotificationsEnabled.rawValue] = String(areNotificationsEnabled)
			info[CodingKeys.isSignUpCompleted.rawValue] = String(isSignUpCompleted)
			return info.isEmpty ? nil : info
		}
	}

	init(id: String, name: PersonNameComponents) {
		self.id = id
		self.name = name
		self.timezone = TimeZone.current
		self.effectiveDate = Calendar.current.startOfDay(for: Date())
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		self.id = try container.decode(String.self, forKey: .id)
		self.name = try container.decode(PersonNameComponents.self, forKey: .name)
		self.sex = try container.decodeIfPresent(OCKBiologicalSex.self, forKey: .sex)
		self.birthday = try container.decodeIfPresent(Date.self, forKey: .birthday)
		self.allergies = try container.decodeIfPresent([String].self, forKey: .allergies)

		self.effectiveDate = try container.decode(Date.self, forKey: .effectiveDate)
		self.createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate)
		self.updatedDate = try container.decodeIfPresent(Date.self, forKey: .updatedDate)
		self.groupIdentifier = try container.decodeIfPresent(String.self, forKey: .groupIdentifier)
		self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
		self.remoteID = try container.decodeIfPresent(String.self, forKey: .remoteID)
		self.source = try container.decodeIfPresent(String.self, forKey: .source)
		self.userInfo = try container.decodeIfPresent(UserInfo.self, forKey: .userInfo)
		self.asset = try container.decodeIfPresent(String.self, forKey: .asset)
		self.timezone = try container.decodeTimeZone(forKey: .timezone)
		if remoteID == nil {
			self.remoteID = userInfo?.fhirId
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(name, forKey: .name)
		try container.encodeIfPresent(sex, forKey: .sex)
		try container.encodeIfPresent(birthday, forKey: .birthday)
		try container.encodeIfPresent(allergies, forKey: .allergies)

		try container.encode(effectiveDate, forKey: .effectiveDate)
		try container.encodeIfPresent(createdDate, forKey: .createdDate)
		try container.encodeIfPresent(updatedDate, forKey: .updatedDate)
		try container.encodeIfPresent(groupIdentifier, forKey: .groupIdentifier)
		try container.encodeIfPresent(tags, forKey: .tags)
		try container.encodeIfPresent(remoteID, forKey: .remoteID)
		try container.encodeIfPresent(source, forKey: .source)
		try container.encodeIfPresent(userInfo, forKey: .userInfo)
		try container.encodeIfPresent(asset, forKey: .asset)
		try container.encode(timezone.secondsFromGMT(), forKey: .timezone)
	}

	private enum CodingKeys: String, CodingKey {
		case id
		case name
		case sex
		case birthday
		case allergies
		case effectiveDate
		case createdDate
		case updatedDate
		case groupIdentifier
		case tags
		case remoteID
		case source
		case userInfo
		case asset
		case notes
		case timezone
	}
}
