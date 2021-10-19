//
//  LoggingManager.swift
//  Allie
//

import FirebaseCrashlytics
import Foundation
import Logging

var ALog: Logger = LoggingManager.createLogger(label: "Logger")

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

enum LoggingManager {
	static var consoleLogLevel: Logger.Level = .info {
		didSet {
			changeLogger(label: ALog.label)
		}
	}

	static var remoteLogLevel: Logger.Level = .info { // remoteConfigManager.remoteLogging.logLevel
		didSet {
			changeLogger(label: ALog.label)
		}
	}

	static var isFileLogginEnabled: Bool {
		get {
			LoggingFile.isEnabled
		}
		set {
			LoggingFile.isEnabled = newValue
		}
	}

	static var fileLogURL: URL? {
		let cachesDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
		return cachesDirectoryURL?.appendingPathComponent("Allie.log")
	}

	static func identify(userId: String?) {
		guard let userId = userId else {
			return
		}
		Crashlytics.crashlytics().setUserID(userId)
	}

	static func createLogger(label: String, consoleLogLevel: Logger.Level = Self.consoleLogLevel, remoteLevel: Logger.Level = Self.remoteLogLevel) -> Logger {
		var fileLogger: LoggingFile?
		if let fileLogURL = Self.fileLogURL {
			fileLogger = try? LoggingFile(to: fileLogURL)
		}

		LoggingSystem.bootstrap { label -> LogHandler in
			var logHandlers: [LogHandler] = []

			var osLog = LoggingOSLog(label: label, category: ProcessInfo.processInfo.processName)
			osLog.logLevel = consoleLogLevel
			logHandlers.append(osLog)
			var crashlyticsLogger = LoggingCrashlytics(label: label)
			crashlyticsLogger.logLevel = remoteLevel
			logHandlers.append(crashlyticsLogger)
			if let fileLogger = fileLogger {
				let fileLogHandler = FileLogHandler(label: label, fileLogger: fileLogger)
				logHandlers.append(fileLogHandler)
			}
			return MultiplexLogHandler(logHandlers)
		}
		let logger = Logger(label: Bundle.main.bundleIdentifier! + "." + label)
		return logger
	}

	static func changeLogger(label: String) {
		ALog = createLogger(label: label)
	}
}

public extension Logger {
	@inlinable
	func error(_ message: @autoclosure () -> Logger.Message = "", error: @autoclosure () -> Error? = nil, metadata: @autoclosure () -> Logger.Metadata? = nil, source: @autoclosure () -> String? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
		var loggerMessage: Logger.Message = message()
		if let error = error() {
			var spacer = " "
			if loggerMessage.description.isEmpty {
				spacer = " "
			}
			loggerMessage = "\(loggerMessage)\(spacer)\(error.localizedDescription)"
			Crashlytics.crashlytics().record(error: error)
		}
		log(level: .error, loggerMessage, metadata: metadata(), source: source(), file: file, function: function, line: line)
	}
}
