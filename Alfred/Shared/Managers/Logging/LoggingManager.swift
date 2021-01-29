//
//  LoggingManager.swift
//  Alfred
//

import FirebaseCrashlytics
import Foundation
import Logging

var ALog: Logger = {
	let level = Logger.Level.info // DataContext.shared.remoteConfigManager.remoteLogging.logLevel
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

enum LoggingManager {
	static func identify(userId: String?) {
		guard let userId = userId else {
			return
		}
		Crashlytics.crashlytics().setUserID(userId)
	}

	static func createLogger(level: Logger.Level, remoteLevel: Logger.Level, label: String) -> Logger {
		LoggingSystem.bootstrap { (label) -> LogHandler in
			var osLog = LoggingOSLog(label: label, category: ProcessInfo.processInfo.processName)
			osLog.logLevel = level
			var crashlyticsLogger = LoggingCrashlytics(label: label)
			crashlyticsLogger.logLevel = remoteLevel
			return MultiplexLogHandler([osLog, crashlyticsLogger])
		}
		let logger = Logger(label: Bundle.main.bundleIdentifier! + "." + label)
		return logger
	}

	static func changeLogger(level: Logger.Level) {
		let logger = createLogger(level: ALog.logLevel, remoteLevel: level, label: ALog.label)
		ALog = logger
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
