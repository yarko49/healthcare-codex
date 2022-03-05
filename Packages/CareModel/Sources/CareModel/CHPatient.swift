//
//  CHPatient.swift
//  Allie
//
//  Created by Waqar Malik on 12/6/20.
//

import BluetoothService
import CareKitStore
import CodexModel
import UIKit

/*
 client ---push-patient-resource---> cloud-endpoint
                                          |
                                    FHIR ID Created
                                          |
 client <---pull-patient-resource--- cloud-endpoint
 */
public typealias CHPatients = [CHPatient]

public struct CHPatient: Codable, Identifiable, Equatable, OCKAnyPatient, AnyItemDeletable, AnyUserInfoExtensible {
	public let id: String
	public var uuid = UUID()
	public var name: PersonNameComponents
	public var sex: OCKBiologicalSex?
	public var birthday: Date?
	public var allergies: [String]?
	public var createdDate: Date
	public var effectiveDate: Date
	public var updatedDate: Date?
	public var deletedDate: Date?

	public var groupIdentifier: String? // shared, active, inactive
	public var tags: [String]?
	public var remoteId: String?
	public var source: String?
	public var userInfo: [String: String]?
	public var asset: String?
	public var timezone: TimeZone
	public var notes: [OCKNote]?
	public var profile = CHProfile()
	public var peripherals: [String: CHPeripheral] = [:]

	public var age: Int? {
		guard let birthday = birthday else {
			return nil
		}
		return Calendar.current.dateComponents(Set([.year]), from: birthday, to: Date()).year
	}

	public var remoteID: String? {
		remoteId
	}

	public struct CHProfile: Codable, Hashable {
		public var email: String?
		public var patientId: String?
		public var userId: String?
		public var phoneNumber: String?
		public var deviceManufacturer: String?
		public var deviceSoftwareVersion: String?
		public var fhirId: String?
		public var heightInInches: Int?
		public var weightInPounds: Int?
		public var isSignUpCompleted: Bool = false

		public var weightInKilograms: Double? {
			guard let lbs = weightInPounds else {
				return nil
			}

			return Double(lbs) * 0.4535924
		}

		public var heightInCentimeters: Double? {
			guard let inches = heightInInches else {
				return nil
			}

			return Double(inches) * 2.54
		}

		public var fhirUUID: UUID? {
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
			case isSignUpCompleted = "signUpCompleted"
		}
	}

	public init(id: String, name: PersonNameComponents) {
		self.id = id
		self.name = name
		self.timezone = TimeZone.current
		self.createdDate = Calendar.current.startOfDay(for: Date())
		self.effectiveDate = createdDate
	}

	public init(from decoder: Decoder) throws {
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
		let pairedPeripherals = try container.decodeIfPresent(Set<CHPeripheral>.self, forKey: .peripherals) ?? []
		self.peripherals = pairedPeripherals.reduce([:]) { partialResult, peripheral in
			var result = partialResult
			result[peripheral.type] = peripheral
			return result
		}

		let monitor = peripherals[GATTServiceBloodPressure.identifier]
		if let bgmMonitor = bgmPeripheral, monitor == nil {
			peripherals[bgmMonitor.type] = bgmMonitor
		}
	}

	public func encode(to encoder: Encoder) throws {
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
		try container.encode(Set(peripherals.values), forKey: .peripherals)
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
		case peripherals
	}

	public static func == (lhs: CHPatient, rhs: CHPatient) -> Bool {
		lhs.id == rhs.id
	}
}

public extension CHPatient {
	@available(*, deprecated)
	var bgmIdentifier: String? {
		get {
			userInfo?["bgmIdentifier"]
		}
		set {
			setUserInfo(string: newValue, forKey: "bgmIdentifier")
		}
	}

	@available(*, deprecated)
	var bgmAddress: String? {
		get {
			userInfo?["bgmAddress"]
		}
		set {
			setUserInfo(string: newValue, forKey: "bgmAddress")
		}
	}

	@available(*, deprecated)
	var bgmLastSync: String? {
		get {
			userInfo?["bgmLastSync"]
		}
		set {
			setUserInfo(string: newValue, forKey: "bgmLastSync")
		}
	}

	@available(*, deprecated)
	var bgmLastSyncDate: String? {
		get {
			userInfo?["bgmLastSyncDate"]
		}
		set {
			setUserInfo(string: newValue, forKey: "bgmLastSyncDate")
		}
	}

	@available(*, deprecated)
	var bgmName: String? {
		get {
			userInfo?["bgmName"]
		}
		set {
			setUserInfo(string: newValue, forKey: "bgmName")
		}
	}
}

public extension PersonNameComponents {
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
