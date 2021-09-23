//
//  LogginCrashlytics.swift
//  Allie
//
//  Created by Waqar Malik on 1/16/21.
//

import FirebaseCrashlytics
import Foundation
import Logging

extension RemoteLogging {
	var logLevel: Logger.Level {
		Logger.Level(rawValue: minimumLevel) ?? .error
	}
}

extension FileLogging {
	var logLevel: Logger.Level {
		Logger.Level(rawValue: minimumLevel) ?? .error
	}
}

public struct LoggingCrashlytics: LogHandler {
	public var metadata: Logger.Metadata = [:] {
		didSet {
			prettyMetadata = prettify(metadata)
		}
	}

	public var logLevel: Logger.Level = .error
	public let label: String

	public init(label: String) {
		self.label = label
	}

	public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
		get {
			metadata[key]
		}
		set(newValue) {
			metadata[key] = newValue
		}
	}

	// swiftlint:disable:next function_parameter_count
	public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
		var combinedPrettyMetadata = prettyMetadata
		if let metadataOverride = metadata, !metadataOverride.isEmpty {
			combinedPrettyMetadata = prettify(self.metadata.merging(metadataOverride) { $1 })
		}

		var formedMessage = message.description
		if combinedPrettyMetadata != nil {
			formedMessage += " -- " + combinedPrettyMetadata!
		}

		let fileURL = URL(fileURLWithPath: file)
		crashlytics.log("\(level.icon))[\(fileURL.lastPathComponent):\(line)] \(formedMessage)")
	}

	private let crashlytics = Crashlytics.crashlytics()
	private var prettyMetadata: String?
	private func prettify(_ metadata: Logger.Metadata) -> String? {
		if metadata.isEmpty {
			return nil
		}
		return metadata.map {
			"\($0)=\($1)"
		}.joined(separator: " ")
	}
}
