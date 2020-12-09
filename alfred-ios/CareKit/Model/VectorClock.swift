//
//  VectorClock.swift
//  alfred-ios
//
//  Created by Waqar Malik on 11/24/20.
//

import CareKitStore
import Foundation
import os.log

public struct VectorClock: Codable, Hashable {
	public var uuid: UUID
	public var objectId: String?
	public var createdAt: Date?
	public var updatedAt: Date?
	public var vector: String?

	public init(uuid: UUID, value: Int64 = 0) {
		self.uuid = uuid
		self.vector = "{\"processes\":[{\"id\":\"\(self.uuid.uuidString)\",\"clock\":\(value)}]}"
		self.createdAt = Date()
		self.updatedAt = Date()
	}

	public func decode(completion: @escaping (OCKRevisionRecord.KnowledgeVector?) -> Void) throws {
		guard let vectorString = vector, !vectorString.isEmpty else {
			let error = URLError(.zeroByteResource)
			os_log(.error, log: .alfred, "vector string missing or empty %@", error.localizedDescription)
			throw error
		}

		guard let data = vectorString.data(using: .utf8) else {
			let error = URLError(.cannotDecodeContentData)
			os_log(.error, log: .alfred, "vector string is not convertable %@", error.localizedDescription)
			throw error
		}
		let cloudVector: OCKRevisionRecord.KnowledgeVector = try JSONDecoder().decode(OCKRevisionRecord.KnowledgeVector.self, from: data)
		completion(cloudVector)
	}

	public func encode(clock: OCKRevisionRecord.KnowledgeVector) throws -> String {
		let json = try JSONEncoder().encode(clock)
		let cloudVectorString = String(data: json, encoding: .utf8)!
		return cloudVectorString
	}
}
