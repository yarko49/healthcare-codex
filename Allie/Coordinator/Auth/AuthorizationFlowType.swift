//
//  AuthorizationFlowType.swift
//  Allie
//
//  Created by Waqar Malik on 1/21/21.
//

import AuthenticationServices
import Foundation

enum AuthorizationFlowType: Hashable, CaseIterable {
	case signIn
	case signUp
}

extension AuthorizationFlowType {
	var googleButtonTitle: String {
		switch self {
		case .signIn:
			return Str.signInWithGoogle
		case .signUp:
			return Str.signUpWithGoogle
		}
	}

	var emailButtonTitle: String {
		switch self {
		case .signIn:
			return Str.signInWithYourEmail
		case .signUp:
			return Str.signUpWithYourEmail
		}
	}

	var modalTitle: String {
		switch self {
		case .signIn:
			return Str.signInModal
		case .signUp:
			return Str.signup
		}
	}

	var appleAuthButtonType: ASAuthorizationAppleIDButton.ButtonType {
		switch self {
		case .signIn:
			return .signIn
		case .signUp:
			return .signUp
		}
	}
}
