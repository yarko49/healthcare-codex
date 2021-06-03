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
			return String.signInWithGoogle
		case .signUp:
			return String.signUpWithGoogle
		}
	}

	var emailButtonTitle: String {
		switch self {
		case .signIn:
			return String.signInWithYourEmail
		case .signUp:
			return String.signUpWithYourEmail
		}
	}

	var modalTitle: String {
		switch self {
		case .signIn:
			return String.signInModal
		case .signUp:
			return String.signup
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
