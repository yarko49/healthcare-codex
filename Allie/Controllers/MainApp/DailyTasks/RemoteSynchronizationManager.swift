//
//  RemoteSynchronizationManager.swift
//  Allie
//
//  Created by Waqar Malik on 11/23/20.
//

import CareKitStore
import Foundation

public final class RemoteSynchronizationManager: OCKRemoteSynchronizable {
	public weak var delegate: OCKRemoteSynchronizationDelegate?
	public var automaticallySynchronizes: Bool

	public init(automaticallySynchronizes: Bool = true) {
		self.automaticallySynchronizes = automaticallySynchronizes
	}

	public func pullRevisions(since knowledgeVector: OCKRevisionRecord.KnowledgeVector, mergeRevision: @escaping (OCKRevisionRecord) -> Void, completion: @escaping (Error?) -> Void) {
		APIClient.client.getCarePlan { result in
			switch result {
			case .failure(let error):
				completion(error)
			case .success(let carePlanResponses):
				let vectorClock = carePlanResponses.vectorClock
				guard let backendRevision = vectorClock["backend"] else {
					let revision = OCKRevisionRecord(entities: [], knowledgeVector: .init())
					mergeRevision(revision)
					return
				}
				ALog.info("\(knowledgeVector), backend revision \(backendRevision)")
				completion(nil)
			}
		}
	}

	public func pushRevisions(deviceRevision: OCKRevisionRecord, completion: @escaping (Error?) -> Void) {
		ALog.info("pushRevisions: Device Revision: \(deviceRevision)")
		completion(nil)
	}

	public func chooseConflictResolution(conflicts: [OCKEntity], completion: @escaping OCKResultClosure<OCKEntity>) {
		completion(.failure(.remoteSynchronizationFailed(reason: "Missing data")))
	}
}
