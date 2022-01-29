//
//  NumberFormatter+Formatters.swift
//  Allie
//
//  Created by Waqar Malik on 10/23/21.
//

import Foundation

public extension NumberFormatter {
	static var valueFormatter: NumberFormatter {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 2
		formatter.locale = Locale.current
		return formatter
	}
}
