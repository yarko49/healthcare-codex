//
//  AuthorizationFlowType.swift
//  Allie
//
//  Created by Waqar Malik on 1/21/21.
//

import AuthenticationServices
import Foundation

enum AuthorizationFlowType: String, Hashable, CaseIterable, CustomStringConvertible {
	case signIn
	case signUp

	var description: String {
		rawValue
	}
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

	var toggleButtonTitle: String? {
		switch self {
		case .signIn:
			return NSLocalizedString("SIGN_UP", comment: "Sign Up")
		case .signUp:
			return NSLocalizedString("LOG_IN", comment: "Log In")
		}
	}

	var message: String? {
		switch self {
		case .signIn:
			return NSLocalizedString("DONT_HAVE_ACCOUNT", comment: "Sign Up")
		case .signUp:
			return NSLocalizedString("ALREADY_HAVE_ACCOUNT", comment: "Already have an Account?")
		}
	}
}
