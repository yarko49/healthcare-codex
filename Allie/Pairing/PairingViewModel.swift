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

	func updateSuccess() {
		pages.append(PairingItem.successItem)
	}

	func updateFailure() {
		pages.append(PairingItem.failureItem)
	}
}
