//
//  UIPageViewController+Allie.swift
//  Allie
//
//  Created by Waqar Malik on 3/20/21.
//

import UIKit

extension UIPageViewController {
	var ch_scrollView: UIScrollView? {
		view.subviews.filter { view in
			view is UIScrollView
		}.first as? UIScrollView
	}
}
