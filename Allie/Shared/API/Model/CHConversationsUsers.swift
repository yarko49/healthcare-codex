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
	let attributesString: String?
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
		case attributesString = "attributes"
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

extension CHConversationsUser {
	var attributes: CHUserAttributes? {
		guard let attrString = attributesString, let data = attrString.data(using: .utf8) else {
			return nil
		}
		let decoder = JSONDecoder()
		do {
			let attributes = try decoder.decode(CHUserAttributes.self, from: data)
			return attributes
		} catch {
			return nil
		}
	}
}

struct CHUserAttributes: Codable, Identifiable {
	let id: String
	let role: String?
	let title: String?
	let userIdentity: String?
	let serviceSid: String?

	enum CodingKeys: String, CodingKey {
		case id = "healthcareProviderTenantId"
		case role
		case title
		case userIdentity
		case serviceSid
	}
}
