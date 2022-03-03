//
//  CHOutcomeResponse.swift
//  Allie
//
//  Created by Waqar Malik on 6/17/21.
//

import Foundation

public struct CHOutcomeResponse: Codable {
	public struct MetaData: Codable {
		public let first: URL
		public let next: URL?
		public let previous: URL?
		public let current: URL

		private enum CodingKeys: String, CodingKey {
			case first
			case next
			case previous
			case current = "self"
		}
	}

	public let metaData: MetaData
	public let outcomes: [CHOutcome]
}
