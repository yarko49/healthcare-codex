//
//  FirebaseUser+Patient.swift
//  Allie
//
//  Created by Waqar Malik on 1/12/21.
//

import FirebaseAuth
import Foundation

protocol RemoteUser {
	var uid: String { get }
	var email: String? { get }
	var phoneNumber: String? { get }
	var displayName: String? { get }
}

extension User: RemoteUser {}
