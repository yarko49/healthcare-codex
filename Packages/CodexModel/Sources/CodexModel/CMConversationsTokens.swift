//
//  CMConversationsTokens.swift
//  Allie
//
//  Created by Waqar Malik on 6/17/21.
//

import Foundation

public struct CMConversationsTokens: Codable {
	public struct Token: Codable, Identifiable {
		public let id: String
		public let accessToken: String
		public let expirationDate: Date
		public let serviceSid: String

		private enum CodingKeys: String, CodingKey {
			case id = "healthcareProviderOrganizationId"
			case accessToken
			case expirationDate = "expires"
			case serviceSid
		}
	}

	public let tokens: [Token] // For now we are assuming only one valid token
}

extension CMConversationsTokens: CustomStringConvertible {
	public var description: String {
		"tokens = \(tokens)"
	}
}

extension CMConversationsTokens.Token: CustomStringConvertible {
	public var description: String {
		"{\nid = \(id)\naccessToken = \(accessToken)\nexpiresAt = \(expirationDate)\n}"
	}
}

extension CMConversationsTokens.Token: CustomDebugStringConvertible {
	public var debugDescription: String {
		"{\nid = \(id)\naccessToken = \(accessToken)\nexpirationDate = \(expirationDate)\nserviceSID = \(serviceSid)\n}"
	}
}
