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

extension APIClient {
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
