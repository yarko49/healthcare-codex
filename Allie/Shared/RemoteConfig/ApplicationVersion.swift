//
//  ApplicationVersion.swift
//  Allie
//
//  Created by Waqar Malik on 10/13/21.
//

import Foundation

struct ApplicationVersion: Codable, Hashable, Equatable, Comparable, LosslessStringConvertible {
	let operatingSystemVersion: OperatingSystemVersion

	/// The build number, i.e. the *0* in 3.11.2-0.
	let buildNumber: Int

	/// The errors that could occur while attempting to parse a string into an `OCKSemanticVersion`.
	enum ParsingError: Error {
		case emptyString
		case tooManySeparators
		case invalidVersion
		case invalidBuildVersion
	}

	/// Initialize by specifying the major, minor, and patch versions.
	init(majorVersion: Int, minorVersion: Int = 0, patchNumber: Int = 0, buildNumber: Int = 0) {
		self.operatingSystemVersion = OperatingSystemVersion(majorVersion: majorVersion, minorVersion: minorVersion, patchVersion: patchNumber)
		self.buildNumber = buildNumber
	}

	init(operatingSystemVersion: OperatingSystemVersion, buildNumber: Int = 0) {
		self.operatingSystemVersion = operatingSystemVersion
		self.buildNumber = buildNumber
	}

	/// Initialize from a string description of the semantic version. This init will fail and return nil if the provided string is
	/// not a valid semantic version.
	init?(_ description: String) {
		do {
			self = try ApplicationVersion.parse(description)
		} catch {
			return nil
		}
	}

	public var description: String {
		"\(operatingSystemVersion)-\(buildNumber)"
	}

	public static func < (lhs: ApplicationVersion, rhs: ApplicationVersion) -> Bool {
		guard lhs.operatingSystemVersion < rhs.operatingSystemVersion else {
			return false
		}
		// Major and minor versions are equal, patch numbers are equal, build numbers are unequal
		if lhs.buildNumber < rhs.buildNumber { return true }
		if lhs.buildNumber > rhs.buildNumber { return false }

		// Major, minor, patch and build numbers all match
		return false
	}

	/// Parses a string into an `OCKSemanticVersion`. Throws if an error occurs.
	/// - Parameter versionString: A string representing the semantic version, e.g. "3.11.2"
	static func parse(_ versionString: String) throws -> ApplicationVersion {
		guard !versionString.isEmpty else {
			throw ParsingError.emptyString
		}

		let majorParts = versionString.split(separator: "-").map { substring in
			String(substring)
		}
		guard majorParts.count <= 2 else {
			throw ParsingError.tooManySeparators
		}

		guard !majorParts.isEmpty else {
			throw ParsingError.invalidVersion
		}

		let versionPart = majorParts[0]
		guard let operatingSystemVersion = OperatingSystemVersion(versionPart) else {
			throw ParsingError.invalidVersion
		}

		let build: Int = try {
			guard majorParts.count > 1 else { return 0 }
			let buildString = majorParts[1]
			guard let build = Int(buildString) else {
				throw ParsingError.invalidBuildVersion
			}
			return build
		}()

		return ApplicationVersion(operatingSystemVersion: operatingSystemVersion, buildNumber: build)
	}
}

extension ApplicationVersion {
	static var current: ApplicationVersion? {
		guard let versionString = Bundle.main.ch_appVersion, let osv = OperatingSystemVersion(versionString) else {
			return nil
		}
		guard let buildNumberString = Bundle.main.ch_buildNumber, let buildNumber = Int(buildNumberString) else {
			return nil
		}
		return ApplicationVersion(operatingSystemVersion: osv, buildNumber: buildNumber)
	}
}
