//
//  LoggingOSLog.swift
//  Allie
//
//  Created by Waqar Malik on 1/16/21.
//

import Foundation

import Logging
import os

public struct LoggingOSLog: LogHandler {
	public var logLevel: Logging.Logger.Level = .info
	public let label: String
	private let oslogger: OSLog

	public init(label: String, category: String) {
		self.label = label
		self.oslogger = OSLog(subsystem: label, category: category)
	}

	// swiftlint:disable:next function_parameter_count
	public func log(level: Logging.Logger.Level, message: Logging.Logger.Message, metadata: Logging.Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
		var combinedPrettyMetadata = prettyMetadata
		if let metadataOverride = metadata, !metadataOverride.isEmpty {
			combinedPrettyMetadata = prettify(
				self.metadata.merging(metadataOverride) {
					$1
				}
			)
		}

		var formedMessage = message.description
		if combinedPrettyMetadata != nil {
			formedMessage += " -- " + combinedPrettyMetadata!
		}
		os_log("%{public}@", log: oslogger, type: OSLogType.from(loggerLevel: level), formedMessage as NSString)
	}

	private var prettyMetadata: String?
	public var metadata = Logger.Metadata() {
		didSet {
			prettyMetadata = prettify(metadata)
		}
	}

	/// Add, remove, or change the logging metadata.
	/// - parameters:
	///    - metadataKey: the key for the metadata item.
	public subscript(metadataKey metadataKey: String) -> Logging.Logger.Metadata.Value? {
		get {
			metadata[metadataKey]
		}
		set {
			metadata[metadataKey] = newValue
		}
	}

	private func prettify(_ metadata: Logging.Logger.Metadata) -> String? {
		if metadata.isEmpty {
			return nil
		}
		return metadata.map {
			"\($0)=\($1)"
		}.joined(separator: " ")
	}
}

extension OSLogType {
	static func from(loggerLevel: Logging.Logger.Level) -> Self {
		switch loggerLevel {
		case .trace:
			/// `OSLog` doesn't have `trace`, so use `debug`
			return .debug
		case .debug:
			return .debug
		case .info:
			return .info
		case .notice:
			/// `OSLog` doesn't have `notice`, so use `info`
			return .info
		case .warning:
			/// `OSLog` doesn't have `warning`, so use `info`
			return .info
		case .error:
			return .error
		case .critical:
			return .fault
		}
	}
}
