//
//  OnboardViewModel.swift
//  Allie
//
//  Created by Waqar Malik on 3/20/21.
//

import UIKit

class OnboardingViewModel: NSObject, UIPageViewControllerDataSource {
	private(set) var viewTypes: [OnboardingScreenType] = [.landing]
	var intialScreenType: OnboardingScreenType = .landing
	var authenticationType: AuthorizationFlowType = .signUp

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let screenTypeable = viewController as? OnboardingScreenTypable else {
			return nil
		}
		return screenTypeable.screenType.viewController
	}

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let screenTypeable = viewController as? OnboardingScreenTypable else {
			return nil
		}
		return screenTypeable.screenType.viewController
	}

	var initialViewController: UIViewController? {
		intialScreenType.viewController
	}
}

extension OnboardingScreenType {
	var viewController: UIViewController? {
		switch self {
		case .landing:
			return OnboardingViewController()
		}
	}
}
