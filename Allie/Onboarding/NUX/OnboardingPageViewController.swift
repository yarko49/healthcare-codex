//
//  OnboardingPageViewController.swift
//  Allie
//
//  Created by Waqar Malik on 3/20/21.
//

import UIKit

class OnboardingPageViewController: UIViewController, UIPageViewControllerDelegate {
	let pageViewController: UIPageViewController = {
		let controller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
		controller.ch_scrollView?.isScrollEnabled = false
		return controller
	}()

	var initialScreenType: OnboardingScreenType {
		get {
			viewModel.intialScreenType
		}
		set {
			viewModel.intialScreenType = newValue
		}
	}

	let viewModel: OnboardingViewModel = {
		let viewModel = OnboardingViewModel()
		return viewModel
	}()

	override open func loadView() {
		addChild(pageViewController)
		view = pageViewController.view
		pageViewController.didMove(toParent: self)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		pageViewController.delegate = self
		pageViewController.dataSource = viewModel
		view.backgroundColor = .onboardingBackground
	}

	private var pageViews: [OnboardingScreenType] = [.landing]
}
