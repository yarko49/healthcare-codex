//
//  String+Capitalizing.swift
//  Allie
//
//  Created by Waqar Malik on 5/8/21.
//

import Foundation

public extension String {
	func capitalizingFirstLetter() -> String {
		prefix(1).capitalized + dropFirst()
	}

	mutating func capitalizeFirstLetter() {
		self = capitalizingFirstLetter()
	}
}
