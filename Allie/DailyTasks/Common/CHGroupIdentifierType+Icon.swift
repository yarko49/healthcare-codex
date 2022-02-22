//
//  CHGroupIdentifierType+Icon.swift
//  Allie
//
//  Created by Waqar Malik on 10/26/21.
//

import UIKit

extension CHGroupIdentifierType {
	var icon: UIImage? {
		switch self {
		case .logInsulin:
			return UIImage(named: "icon-insulin")
		case .symptoms:
			return UIImage(named: "icon-symptoms")
		case .featuredContent:
			return UIImage(named: "icon-life-style")
		case .simple:
			return UIImage(named: "icon-life-style")
		case .grid:
			return UIImage(named: "icon-medication")
		default:
			return nil
		}
	}
}
