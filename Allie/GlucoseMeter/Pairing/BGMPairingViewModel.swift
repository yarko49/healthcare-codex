//
//  BGMPairingViewModel.swift
//  Allie
//
//  Created by Waqar Malik on 8/23/21.
//

import UIKit

class BGMPairingViewModel: NSObject, UIPageViewControllerDataSource {
	var pages: [BGMPairingItem] = BGMPairingItem.items
	var isSucess: Bool = true

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

	func viewControllerAt(index: Int) -> BGMPairingPageViewController? {
		if pages.isEmpty || index >= pages.count {
			return nil
		}
		let viewController = BGMPairingPageViewController()
		viewController.item = pages[index]
		return viewController
	}

	func firstIndex(of viewController: UIViewController) -> Int? {
		if let item = (viewController as? BGMPairingPageViewController)?.item {
			return pages.firstIndex(of: item)
		} else {
			return nil
		}
	}

	func updateSuccess() {
		pages.append(BGMPairingItem.successItem)
	}

	func updateFailure() {
		pages.append(BGMPairingItem.failureItem)
	}
}
