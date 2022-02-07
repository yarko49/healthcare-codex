//
//  Ext_UIView.swift
//  Allie
//

import UIKit

extension UIView {
	func fixInView(_ container: UIView!) {
		translatesAutoresizingMaskIntoConstraints = false
		frame = container.frame
		container.addSubview(self)
		NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
		NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
		NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
		NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
	}

	func setShadow() {
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOffset = CGSize(width: 0, height: 1.0)
		layer.shadowRadius = 2.0
		layer.shadowOpacity = 0.2
		layer.masksToBounds = false
	}

	func clearShadow() {
		layer.shadowColor = UIColor.clear.cgColor
		layer.shadowOffset = CGSize(width: 0, height: 0.0)
		layer.shadowRadius = 0.0
		layer.shadowOpacity = 0.0
		layer.masksToBounds = false
	}

	func fixHeaderInView(_ container: UIView!) {
		translatesAutoresizingMaskIntoConstraints = false
		frame = container.frame
		container.addSubview(self)

		NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
		NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
		NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
		NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
	}

    var safeAreaBottom: CGFloat {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            if let bottomPadding = window?.safeAreaInsets.bottom {
                return bottomPadding
            }
            return 0
        }
        return 0
    }
}
