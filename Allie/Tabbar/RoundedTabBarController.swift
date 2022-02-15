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
		layer.path = UIBezierPath(roundedRect: CGRect(x: 20, y: tabBar.bounds.minY - 35, width: tabBar.bounds.width - 40.0, height: 72),
		                          cornerRadius: tabBar.frame.height / 2).cgPath
		layer.shadowColor = UIColor.darkGray.cgColor
		layer.shadowOffset = CGSize(width: 5, height: 5)
		layer.shadowRadius = 36.0
		layer.shadowOpacity = 0.7
		layer.opacity = 1.0
		layer.isHidden = false
		layer.masksToBounds = false
		layer.fillColor = UIColor.white.cgColor
		tabBar.layer.insertSublayer(layer, at: 0)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		if let items = tabBar.items {
			items.forEach { item in
				item.imageInsets = UIEdgeInsets(top: -20, left: 0, bottom: 20, right: 0)
			}
			tabBar.itemWidth = CGFloat(tabBar.bounds.width - 40.0) / CGFloat(viewControllers!.count)
			tabBar.itemPositioning = .centered
		}
	}
}
