//
//  DataContext+Logging.swift
//  alfred-ios
//

import Foundation
import FirebaseCrashlytics

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
