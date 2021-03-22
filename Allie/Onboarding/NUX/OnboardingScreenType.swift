//
//  OnboardScreenType.swift
//  Allie
//
//  Created by Waqar Malik on 3/20/21.
//

import UIKit

enum OnboardingScreenType: String, Hashable {
	case landing
}

protocol OnboardingScreenTypable {
	var screenType: OnboardingScreenType { get }
}
