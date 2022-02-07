//
//  RoundedTabBarController.swift
//  Allie
//
//  Created by embedded system mac on 2/6/22.
//

import UIKit

class RoundedTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.backgroundColor = .clear
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: CGRect(x: 20, y: tabBar.bounds.minY - 35, width: tabBar.bounds.width - 40.0, height: 72),
                                  cornerRadius: self.tabBar.frame.height / 2).cgPath
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shadowRadius = 36.0
        layer.shadowOpacity = 0.7
        layer.opacity = 1.0
        layer.isHidden = false
        layer.masksToBounds = false
        layer.fillColor = UIColor.white.cgColor
        self.tabBar.layer.insertSublayer(layer, at: 0)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let items = self.tabBar.items {
            items.forEach { item in
                item.imageInsets = UIEdgeInsets(top: -20, left: 0, bottom: 20, right: 0)
            }
            self.tabBar.itemWidth = CGFloat(self.tabBar.bounds.width - 40.0) / CGFloat(self.viewControllers!.count)
            self.tabBar.itemPositioning = .centered
        }
    }

}
