//
//  CHConversationsUsers.swift
//  Allie
//
//  Created by Waqar Malik on 7/22/21.
//

import Foundation

struct CHConversationsUsers: Codable {
	let users: [CHConversationsUser]

	var usersByKey: [String: CHConversationsUser] {
		users.reduce([:]) { result, item in
			var newResult = result
			newResult[item.id] = item
			return newResult
		}
	}
}

struct CHConversationsUser: Codable, Identifiable {
	let id: String
	let name: String
	let accountSID: String?
	let attributes: String?
	let chatServiceSID: String?
	let createdDate: Date?
	let updatedDate: Date?
	let isNotifiable: Bool?
	let isOnline: Bool?
	let roleSID: String?
	let sid: String?
	let url: URL?

	enum CodingKeys: String, CodingKey {
		case accountSID = "account_sid"
		case attributes
		case chatServiceSID = "chat_service_sid"
		case createdDate = "date_created"
		case updatedDate = "date_updated"
		case name = "friendly_name"
		case id = "identity"
		case isNotifiable = "is_notifiable"
		case isOnline = "is_online"
		case roleSID = "role_sid"
		case sid
		case url
	}
}
