//
//  AuthenticationToken.swift
//  Allie
//
//  Created by Waqar Malik on 5/23/21.
//

import Firebase
import FirebaseAuth
import Foundation

public struct AuthenticationToken: Codable, Hashable {
	let token: String
	let expirationDate: Date
}

public extension AuthenticationToken {
	init?(result: AuthTokenResult?) {
		guard let token = result?.token, let expirationDate = result?.expirationDate else {
			return nil
		}
		self.token = token
		self.expirationDate = expirationDate
	}
}

extension AuthenticationToken: CustomStringConvertible {
	public var description: String {
		"{token: \(token)\nexpirationDate: \(expirationDate)}"
	}
}
