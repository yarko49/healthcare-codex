//
//  RequestPostProcessor.swift
//  alfred-ios
//

import Foundation
import Alamofire

class RequestPostProcessor {
    static func processResponse(_ responseData: Data?, error: Error, url: String?) {
        let afError = error as? AFError
        let errorToSend = (afError?.underlyingError ?? error) as NSError
        var userInfo = errorToSend.userInfo
        userInfo["message"] = error.localizedDescription
        userInfo["url"] = url
        let crashlyticsError = NSError(domain: errorToSend.domain, code: errorToSend.code, userInfo: userInfo)
        DataContext.shared.logError(crashlyticsError)
    }
}
