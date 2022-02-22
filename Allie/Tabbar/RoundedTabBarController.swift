//
//  RoundedTabBarController.swift
//  Allie
//
//  Created by Onseen on 2/6/22.
//

import UIKit

class RoundedTabBarController: UITabBarController {
	override func viewDidLoad() {
		super.viewDidLoad()
		tabBar.backgroundColor = .clear
		tabBar.tintColor = .mainBlue
		let layer = CAShapeLayer()
		layer.path = UIBezierPath(roundedRect: CGRect(x: 20, y: tabBar.bounds.minY - 5, width: tabBar.bounds.width - 40.0, height: 72),
		                          cornerRadius: tabBar.frame.height / 2).cgPath
		layer.shadowColor = UIColor.darkGray.cgColor
		layer.shadowOffset = CGSize(width: 5, height: 5)
		layer.shadowRadius = 36.0
		layer.shadowOpacity = 0.8
		layer.opacity = 1.0
		layer.isHidden = false
		layer.masksToBounds = false
		layer.fillColor = UIColor.white.cgColor
		tabBar.layer.insertSublayer(layer, at: 0)
	}

	override func viewDidLayoutSubviews() {
		tabBar.invalidateIntrinsicContentSize()
		var tabFrame = tabBar.frame
		tabFrame.size.height = 72
		tabFrame.origin.y = view.frame.size.height - 120
		tabBar.frame = tabFrame

		super.viewDidLayoutSubviews()

		tabBar.itemWidth = CGFloat(tabBar.bounds.width - 40.0) / CGFloat(viewControllers!.count)
		tabBar.itemPositioning = .centered
	}
}
