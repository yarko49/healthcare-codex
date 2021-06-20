//
//  FirebaseAuth+Listners.swift
//  Allie
//
//  Created by Waqar Malik on 6/19/21.
//

import Combine
import FirebaseAuth
import Foundation

extension Auth {
	func ch_authStateDidChangePublisher() -> AnyPublisher<User?, Never> {
		let subject = PassthroughSubject<User?, Never>()
		let handle = addStateDidChangeListener { _, user in
			subject.send(user)
		}
		return subject
			.handleEvents(receiveCancel: {
				self.removeStateDidChangeListener(handle)
			})
			.eraseToAnyPublisher()
	}

	func ch_idTokenDidChangePublisher() -> AnyPublisher<User?, Never> {
		let subject = PassthroughSubject<User?, Never>()
		let handle = addIDTokenDidChangeListener { _, user in
			subject.send(user)
		}
		return subject
			.handleEvents(receiveCancel: {
				self.removeIDTokenDidChangeListener(handle)
			})
			.eraseToAnyPublisher()
	}
}
