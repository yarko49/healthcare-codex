//
//  OperatingSystemVersion+Comparable.swift
//  Allie
//
//  Created by Waqar Malik on 10/13/21.
//

import CareKitStore
import Foundation

extension OperatingSystemVersion: Hashable, Equatable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(majorVersion.hashValue)
		hasher.combine(minorVersion.hashValue)
		hasher.combine(patchVersion.hashValue)
	}

	public static func == (lhs: OperatingSystemVersion, rhs: OperatingSystemVersion) -> Bool {
		lhs.majorVersion == rhs.majorVersion && lhs.minorVersion == rhs.minorVersion && rhs.patchVersion == rhs.patchVersion
	}
}

extension OperatingSystemVersion: Comparable {
	public static func < (lhs: OperatingSystemVersion, rhs: OperatingSystemVersion) -> Bool {
		// Major versions are unequal
		if lhs.majorVersion < rhs.majorVersion { return true }
		if lhs.majorVersion > rhs.majorVersion { return false }

		// Major versions are equal, minor versions are unequal
		if lhs.minorVersion < rhs.minorVersion { return true }
		if lhs.minorVersion > rhs.minorVersion { return false }

		// Major and minor versions are equal, patch numbers are unequal
		if lhs.patchVersion < rhs.patchVersion { return true }
		if lhs.patchVersion > rhs.patchVersion { return false }

		// Major, minor, and patch numbers all match
		return false
	}
}

extension OperatingSystemVersion: LosslessStringConvertible {
	/// The errors that could occur while attempting to parse a string into an `OperatingSystemVersion`.
	enum ParsingError: Error {
		case emptyString
		case tooManySeparators
		case invalidMajorVersion
		case invalidMinorVersion
		case invalidPatchVersion
	}

	public init?(_ description: String) {
		do {
			self = try OperatingSystemVersion.parse(description)
		} catch {
			return nil
		}
	}

	public var description: String {
		"\(majorVersion).\(minorVersion).\(patchVersion)"
	}

	public static func parse(_ versionString: String) throws -> OperatingSystemVersion {
		guard !versionString.isEmpty else { throw ParsingError.emptyString }
		let parts = versionString.split(separator: ".").map { Int($0) }
		guard parts.count <= 3 else { throw ParsingError.tooManySeparators }

		guard let major = parts[0] else { throw ParsingError.invalidMajorVersion }

		let minor: Int = try {
			guard parts.count > 1 else { return 0 }
			guard let minor = parts[1] else { throw ParsingError.invalidMinorVersion }
			return minor
		}()

		let patch: Int = try {
			guard parts.count > 2 else { return 0 }
			guard let patch = parts[2] else { throw ParsingError.invalidPatchVersion }
			return patch
		}()

		return OperatingSystemVersion(majorVersion: major, minorVersion: minor, patchVersion: patch)
	}
}
