//
//  SearchParameter.swift
//  Allie
//
//  Created by Waqar Malik on 12/17/20.
//

import Foundation

struct SearchParameter: Codable {
	var sort: String?
	var count: Int?
	var code: String?

	enum CodingKeys: String, CodingKey {
		case sort
		case count
		case code
	}
}
