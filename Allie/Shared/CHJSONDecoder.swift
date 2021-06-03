//
//  CHJSONDecoder.swift
//  Allie
//
//  Created by Waqar Malik on 12/7/20.
//

import Foundation

public final class CHJSONDecoder: JSONDecoder {
	override public init() {
		super.init()
		self.dateDecodingStrategy = .standardFormats
	}
}
