//
//  DataContext+Logging.swift
//  Alfred
//

import FirebaseCrashlytics
import Foundation

extension DataContext {
	func identifyCrashlytics() {
		if let userId = DataContext.shared.userModel?.userID {
			LoggingManager.identify(userId: userId)
		}
	}

	func logError(_ error: Error) {
		LoggingManager.log(error)
	}
}
