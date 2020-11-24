//
//  Clock.swift
//  alfred-ios
//
//  Created by Waqar Malik on 11/24/20.
//

import CareKitStore
import Foundation

struct Clock: Codable, Hashable {
	var uuid: UUID
	var objectId: String?
	var createdAt: Date?
	var updatedAt: Date?
	var vector: String?

	init(uuid: UUID, value: Int64 = 0) {
		self.uuid = uuid
		self.vector = "{\"processes\":[{\"id\":\"\(self.uuid.uuidString)\",\"clock\":\(value)}]}"
		self.createdAt = Date()
		self.updatedAt = Date()
	}

	func decode(completion: @escaping (OCKRevisionRecord.KnowledgeVector?) -> Void) throws {
		guard let vectorString = vector, !vectorString.isEmpty else {
			let error = URLError(.zeroByteResource)
			log(.error, "vector string missing or empty", error: error)
			throw error
		}

		guard let data = vectorString.data(using: .utf8) else {
			let error = URLError(.cannotDecodeContentData)
			log(.error, "vector string is not convertable", error: error)
			throw error
		}
		let cloudVector: OCKRevisionRecord.KnowledgeVector = try JSONDecoder().decode(OCKRevisionRecord.KnowledgeVector.self, from: data)
		completion(cloudVector)
	}

	func encode(clock: OCKRevisionRecord.KnowledgeVector) throws -> String {
		let json = try JSONEncoder().encode(clock)
		let cloudVectorString = String(data: json, encoding: .utf8)!
		return cloudVectorString
	}
}
