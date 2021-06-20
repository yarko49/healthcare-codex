//
//  CHOutcomeResponse.swift
//  Allie
//
//  Created by Waqar Malik on 6/17/21.
//

import Foundation

struct CHOutcomeResponse: Codable {
	struct MetaData: Codable {
		let first: URL
		let next: URL?
		let previous: URL?
		let current: URL

		private enum CodingKeys: String, CodingKey {
			case first
			case next
			case previous
			case current = "self"
		}
	}

	let metaData: MetaData
	let outcomes: [CHOutcome]
}
