//
//  LoggingManager.swift
//  alfred-ios
//

import FirebaseCrashlytics
import Foundation

class LoggingManager {
	static func identify(userId: String) {
		Crashlytics.crashlytics().setUserID(userId)
	}

	static func log(_ error: Error) {
		Crashlytics.crashlytics().record(error: error)
	}
}
