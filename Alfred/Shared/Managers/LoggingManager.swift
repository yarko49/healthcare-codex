//
//  LoggingManager.swift
//  Alfred
//

import FirebaseCrashlytics
import Foundation
import Logging

var ALog: Logger = {
	let level = DataContext.shared.remoteConfigManager.remoteLogging.logLevel
	return LoggingManager.createLogger(level: level, label: "Logger")
}()

extension RemoteLogging {
	var logLevel: Logger.Level {
		Logger.Level(rawValue: minimumLevel) ?? .error
	}
}

enum LoggingManager {
	static func identify(userId: String) {
		Crashlytics.crashlytics().setUserID(userId)
	}

	static func createLogger(level: Logger.Level, label: String) -> Logger {
		LoggingSystem.bootstrap { (label) -> LogHandler in
			let streamLogger = StreamLogHandler.standardError(label: label)
			var crashlyticsLogger = LoggingCrashlytics(label: label)
			crashlyticsLogger.logLevel = level

			return MultiplexLogHandler([streamLogger, crashlyticsLogger])
		}
		return Logger(label: Bundle.main.bundleIdentifier! + "." + label)
	}

	static func changeLogger(level: Logger.Level) {
		let logger = createLogger(level: level, label: ALog.label)
		ALog = logger
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

		crashlytics.log("\(icon(level: level)) [\(source)]:\(line), \(formedMessage)")
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

	private func icon(level: Logger.Level) -> String {
		switch level {
		case .critical:
			return "🔥"
		case .error:
			return "🛑"
		case .debug:
			return "🐞"
		case .info:
			return "❗️"
		case .notice:
			return "📜"
		case .warning:
			return "⚠️"
		case .trace:
			return "📡"
		}
	}
}
