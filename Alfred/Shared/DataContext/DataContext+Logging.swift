//
//  DataContext+Logging.swift
//  Alfred
//

import FirebaseCrashlytics
import Foundation

extension DataContext {
	func identifyCrashlytics() {
		if let userId = userModel?.userID {
			LoggingManager.identify(userId: userId)
		}
	}
}
