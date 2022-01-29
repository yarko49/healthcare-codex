//
//  CMåConversationsUsers.swift
//  Allie
//
//  Created by Waqar Malik on 7/22/21.
//

import Foundation

public struct CMConversationsUsers: Codable {
	public let users: [CMConversationsUser]

	public var usersByKey: [String: CMConversationsUser] {
		users.reduce([:]) { result, item in
			var newResult = result
			newResult[item.id] = item
			return newResult
		}
	}
}

public struct CMConversationsUser: Codable, Identifiable {
	public let id: String
	public let name: String
	public let accountSID: String?
	public let attributesString: String?
	public let chatServiceSID: String?
	public let createdDate: Date?
	public let updatedDate: Date?
	public let isNotifiable: Bool?
	public let isOnline: Bool?
	public let roleSID: String?
	public let sid: String?
	public let url: URL?

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

public extension CMConversationsUser {
	var attributes: CMUserAttributes? {
		guard let attrString = attributesString, let data = attrString.data(using: .utf8) else {
			return nil
		}
		let decoder = JSONDecoder()
		do {
			let attributes = try decoder.decode(CMUserAttributes.self, from: data)
			return attributes
		} catch {
			return nil
		}
	}
}

public struct CMUserAttributes: Codable, Identifiable {
	public let id: String
	public let role: String?
	public let title: String?
	public let userIdentity: String?
	public let serviceSid: String?

	enum CodingKeys: String, CodingKey {
		case id = "healthcareProviderTenantId"
		case role
		case title
		case userIdentity
		case serviceSid
	}
}
