//
//  HomeNotification.swift
//  alfred-ios
//

import Foundation

//TODO: This model is a fake for testing purpose. Don't forget to replace it with the proper one when time comes.

struct HomeNotificationList: Codable {
    let data: [HomeNotification]
}

enum HomeNotificationType: Hashable, Equatable {
    case behavioralNudge
    case questionaire
    case noType
    
    init(rawValue: String) {
        switch rawValue {
        case "behavioralNudge":  self = .behavioralNudge
        case "questionaire": self = .questionaire
        default: self = .noType
        }
    }
}

struct HomeNotification: Codable {
    
    let text: String
    let type: String
    
    var getHomeNotificationType: HomeNotificationType {
        return HomeNotificationType(rawValue: type)
    }

    enum CodingKeys: String, CodingKey {
        case text = "text"
        case type = "type"
    }
    
}
