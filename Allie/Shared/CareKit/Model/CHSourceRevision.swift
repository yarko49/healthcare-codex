//
//  CHSourceRevision.swift
//  Allie
//
//  Created by Waqar Malik on 4/22/21.
//

import Foundation
import HealthKit

public struct CHSource: Codable {
	public let name: String
	public let bundleIdentifier: String
}

extension CHSource {
	init(source: HKSource) {
		self.name = source.name
		self.bundleIdentifier = source.bundleIdentifier
	}
}

public struct CHSourceRevision: Codable {
	public let source: CHSource?
	public let version: String?
	public let productType: String?
	public let operationSystemVersion: OperatingSystemVersion
}

extension OperatingSystemVersion: Codable {
	public init(from decoder: Decoder) throws {
		self.init()
		let container = try decoder.container(keyedBy: CodingKeys.self)
		majorVersion = try container.decode(Int.self, forKey: .majorVersion)
		minorVersion = try container.decode(Int.self, forKey: .minorVersion)
		patchVersion = try container.decode(Int.self, forKey: .patchVersion)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(majorVersion, forKey: .majorVersion)
		try container.encode(minorVersion, forKey: .minorVersion)
		try container.encode(patchVersion, forKey: .patchVersion)
	}

	private enum CodingKeys: String, CodingKey {
		case majorVersion
		case minorVersion
		case patchVersion
	}
}
