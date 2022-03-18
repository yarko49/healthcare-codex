//
//  PairingViewModel.swift
//  Allie
//
//  Created by Waqar Malik on 8/23/21.
//

import UIKit

class PairingViewModel: NSObject, UIPageViewControllerDataSource {
	var pages: [PairingItem]
	var isSucess: Bool = true

	required init(pages: [PairingItem]) {
		self.pages = pages
		super.init()
	}

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let index = firstIndex(of: viewController), index > 0 else {
			return nil
		}
		return viewControllerAt(index: index - 1)
	}

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let index = firstIndex(of: viewController), index < pages.count else {
			return nil
		}
		return viewControllerAt(index: index + 1)
	}

	func viewControllerAt(index: Int) -> PairingPageViewController? {
		if pages.isEmpty || index >= pages.count {
			return nil
		}
		let viewController = PairingPageViewController()
		viewController.item = pages[index]
		return viewController
	}

	func firstIndex(of viewController: UIViewController) -> Int? {
		if let item = (viewController as? PairingPageViewController)?.item {
			return pages.firstIndex(of: item)
		} else {
			return nil
		}
	}

	func identifier(forPage page: Int) -> String? {
		guard page < pages.count else {
			return nil
		}
		return pages[page].id
	}

	func page(forIdentifier identifier: String) -> Int? {
		let page = pages.firstIndex { item in
			item.id == identifier
		}

		return page
	}

	var containsSuccess: Bool {
		containsPage(forIdentifier: "success")
	}

	var containsFailure: Bool {
		containsPage(forIdentifier: "failure")
	}

	func containsPage(forIdentifier identifier: String) -> Bool {
		let item = pages.first { item in
			item.id == identifier
		}
		return item != nil
	}

	func updateSuccess() {
		if !containsSuccess {
			pages.append(PairingItem.successItem)
		}
	}

	func updateFailure() {
		if !containsFailure {
			pages.append(PairingItem.failureItem)
		}
	}
}
