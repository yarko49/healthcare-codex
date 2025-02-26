//
//  CHConversationsTokens.swift
//  Allie
//
//  Created by Waqar Malik on 6/17/21.
//

import Foundation

struct CHConversationsTokens: Codable {
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

extension CHConversationsTokens: CustomStringConvertible {
	var description: String {
		"tokens = \(tokens)"
	}
}

extension CHConversationsTokens.Token: CustomStringConvertible {
	var description: String {
		"{\nid = \(id)\naccessToken = \(accessToken)\nexpiresAt = \(expirationDate)\n}"
	}
}

extension CHConversationsTokens.Token: CustomDebugStringConvertible {
	var debugDescription: String {
		"{\nid = \(id)\naccessToken = \(accessToken)\nexpirationDate = \(expirationDate)\nserviceSID = \(serviceSid)\n}"
	}
}
