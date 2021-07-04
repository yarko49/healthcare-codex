//
//  CHConversationsResponse.swift
//  Allie
//
//  Created by Waqar Malik on 6/17/21.
//

import Foundation

struct CHConversations: Codable {
	struct Token: Codable, Identifiable {
		let id: String
		let accessToken: String
		let expirationDate: Date
		let serviceSid: String

		private enum CodingKeys: String, CodingKey {
			case id = "healthcareProviderOrganizationId"
			case accessToken
			case expirationDate = "expires"
			case serviceSid
		}
	}

	let tokens: [Token] // For now we are assuming only one valid token
}

extension CHConversations: CustomStringConvertible {
	var description: String {
		"toknes = \(tokens)"
	}
}

extension CHConversations.Token: CustomStringConvertible {
	var description: String {
		"{\nid = \(id)\naccessToken = \(accessToken)\nexpiresAt = \(expirationDate)\n}"
	}
}

extension CHConversations.Token: CustomDebugStringConvertible {
	var debugDescription: String {
		"{\nid = \(id)\naccessToken = \(accessToken)\nexpirationDate = \(expirationDate)\nserviceSID = \(serviceSid)\n}"
	}
}
