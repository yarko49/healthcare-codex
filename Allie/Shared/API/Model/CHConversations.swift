//
//  CHConversationsResponse.swift
//  Allie
//
//  Created by Waqar Malik on 6/17/21.
//

import Foundation

struct CHConversations: Codable {
	struct Token: Codable {
		let id: String
		let accessToken: String
		let expirationDate: Date
		let serviceSid: String

		private enum CodingKeys: String, CodingKey {
			case id = "healthcareProviderTenantID"
			case accessToken
			case expirationDate = "expires"
			case serviceSid
		}
	}

	let tokens: Token
}
