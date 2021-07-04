//
//  AuthenticationToken.swift
//  Allie
//
//  Created by Waqar Malik on 5/23/21.
//

import Firebase
import FirebaseAuth
import Foundation

struct AuthenticationToken: Codable, Hashable {
	let token: String
	let expirationDate: Date
}

extension AuthenticationToken {
	init?(result: AuthTokenResult?) {
		guard let token = result?.token, let expirationDate = result?.expirationDate else {
			return nil
		}
		self.token = token
		self.expirationDate = expirationDate
	}
}

extension AuthenticationToken: CustomStringConvertible {
	var description: String {
		"{token: \(token)\nexpirationDate: \(expirationDate)}"
	}
}
