//
//  CompanyIdentifier.swift
//
//
//  Created by Waqar Malik on 12/11/21.
//

import Foundation

public enum CompanyIdentifier: UInt16 {
	case omron = 0x020E
}

extension CompanyIdentifier {
	var name: String {
		switch self {
		case .omron:
			return "Omron Healthcare Co., LTD"
		}
	}
}
