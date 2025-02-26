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
		default:
			return nil
		}
	}
}
