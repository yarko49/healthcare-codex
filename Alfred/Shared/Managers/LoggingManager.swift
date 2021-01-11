//
//  LoggingManager.swift
//  Alfred
//

import FirebaseCrashlytics
import Foundation
import Logging

var ALog: Logger = {
	let level = DataContext.shared.remoteConfigManager.remoteLogging.logLevel
	return LoggingManager.createLogger(level: .info, remoteLevel: level, label: "Logger")
}()

extension Logger.Level {
	var icon: String {
		switch self {
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

extension RemoteLogging {
	var logLevel: Logger.Level {
		Logger.Level(rawValue: minimumLevel) ?? .error
	}
}

enum LoggingManager {
	static func identify(userId: String) {
		Crashlytics.crashlytics().setUserID(userId)
	}

	static func createLogger(level: Logger.Level, remoteLevel: Logger.Level, label: String) -> Logger {
		LoggingSystem.bootstrap { (label) -> LogHandler in
			var streamLogger = ConsoleLogHandler.standardError(label: label)
			streamLogger.logLevel = level
			var crashlyticsLogger = CrashlyticsLogger(label: label)
			crashlyticsLogger.logLevel = remoteLevel
			return MultiplexLogHandler([streamLogger, crashlyticsLogger])
		}
		let logger = Logger(label: Bundle.main.bundleIdentifier! + "." + label)
		return logger
	}

	static func changeLogger(level: Logger.Level) {
		let logger = createLogger(level: ALog.logLevel, remoteLevel: level, label: ALog.label)
		ALog = logger
	}
}

public struct CrashlyticsLogger: LogHandler {
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

public struct ConsoleLogHandler: LogHandler {
	/// Factory that makes a `StreamLogHandler` to directs its output to `stdout`
	public static func standardOutput(label: String) -> ConsoleLogHandler {
		ConsoleLogHandler(label: label, stream: StdioOutputStream.stdout)
	}

	public static func standardError(label: String) -> ConsoleLogHandler {
		ConsoleLogHandler(label: label, stream: StdioOutputStream.stderr)
	}

	private let stream: TextOutputStream
	private let label: String
	let processName = ProcessInfo.processInfo.processName

	public var logLevel: Logger.Level = .info

	private var prettyMetadata: String?
	public var metadata = Logger.Metadata() {
		didSet {
			prettyMetadata = prettify(metadata)
		}
	}

	public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
		get {
			metadata[metadataKey]
		}
		set {
			metadata[metadataKey] = newValue
		}
	}

	// internal for testing only
	internal init(label: String, stream: TextOutputStream) {
		self.label = label
		self.stream = stream
	}

	// swiftlint:disable:next function_parameter_count
	public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
		let prettyMetadata = metadata?.isEmpty ?? true
			? self.prettyMetadata
			: prettify(self.metadata.merging(metadata!, uniquingKeysWith: { _, new in new }))

		var stream = self.stream
		let fileURL = URL(fileURLWithPath: file)
		stream.write("\(timestamp) |\(level.icon)[\(processName)][\(fileURL.lastPathComponent):\(line)]\(prettyMetadata.map { " \($0)" } ?? "") \(message)\n")
	}

	private func prettify(_ metadata: Logger.Metadata) -> String? {
		!metadata.isEmpty ? metadata.map { "\($0)=\($1)" }.joined(separator: " ") : nil
	}

	private let formatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
		return formatter
	}()

	private var timestamp: String {
		formatter.string(from: Date())
	}
}

internal struct StdioOutputStream: TextOutputStream {
	internal let file: UnsafeMutablePointer<FILE>
	internal let flushMode: FlushMode

	internal func write(_ string: String) {
		string.withCString { ptr in
			flockfile(self.file)
			defer {
				funlockfile(self.file)
			}
			_ = fputs(ptr, self.file)
			if case .always = self.flushMode {
				self.flush()
			}
		}
	}

	internal func flush() {
		_ = fflush(file)
	}

	internal static let stderr = StdioOutputStream(file: Darwin.stderr, flushMode: .always)
	internal static let stdout = StdioOutputStream(file: Darwin.stdout, flushMode: .always)

	internal enum FlushMode {
		case undefined
		case always
	}
}
