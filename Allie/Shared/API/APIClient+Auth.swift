//
//  APIClient+Auth.swift
//  Allie
//
//  Created by Waqar Malik on 6/4/21.
//

import Combine
import Firebase
import FirebaseAuth
import Foundation

public extension APIClient {
	func firebaseAuthenticationToken() async throws -> AuthenticationToken {
		guard let currentUser = Auth.auth().currentUser else {
			throw AllieError.missing("User not logged in")
		}
		let result = try await currentUser.getIDTokenResult(forcingRefresh: false)
		guard let token = AuthenticationToken(result: result) else {
			throw URLError(.userCancelledAuthentication)
		}
		return token
	}

	func firebaseAuthenticationToken() -> Future<AuthenticationToken, Error> {
		Future { promise in
			guard let currentUser = Auth.auth().currentUser else {
				promise(.failure(AllieError.missing("User not logged in")))
				return
			}
			currentUser.getIDTokenResult { result, error in
				if let error = error {
					promise(.failure(error))
					return
				}

				guard let token = AuthenticationToken(result: result) else {
					promise(.failure(URLError(.userCancelledAuthentication)))
					return
				}

				promise(.success(token))
			}
		}
	}
}
