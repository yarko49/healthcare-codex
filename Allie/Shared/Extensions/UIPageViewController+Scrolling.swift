//
//  UIPageViewController+Scrolling.swift
//  Allie
//
//  Created by Waqar Malik on 1/12/22.
//

import UIKit

extension UIPageViewController {
	var isPagingEnabled: Bool {
		get {
			scrollView?.isScrollEnabled ?? false
		}
		set {
			scrollView?.isScrollEnabled = newValue
		}
	}

	var scrollView: UIScrollView? {
		view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
	}
}
