//
//  AuthenticaionToken.swift
//  Allie
//
//  Created by Waqar Malik on 5/23/21.
//

import FirebaseAuth
import Foundation

struct AuthenticaionToken: Codable, Hashable {
	let token: String
	let expirationDate: Date
}

extension AuthenticaionToken {
	init?(result: AuthTokenResult?) {
		guard let token = result?.token, let expirationDate = result?.expirationDate else {
			return nil
		}
		self.token = token
		self.expirationDate = expirationDate
	}
}

extension AuthenticaionToken: CustomStringConvertible {
	var description: String {
		"{token: \(token)\nexpirationDate: \(expirationDate)}"
	}
}
