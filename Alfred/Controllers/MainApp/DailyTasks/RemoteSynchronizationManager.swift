//
//  RemoteSynchronizationManager.swift
//  Alfred
//
//  Created by Waqar Malik on 11/23/20.
//

import CareKitStore
import Foundation

public final class RemoteSynchronizationManager: OCKRemoteSynchronizable {
	public weak var delegate: OCKRemoteSynchronizationDelegate?
	public var automaticallySynchronizes: Bool
	public var mergeConflictResolutionPolicy: OCKMergeConflictResolutionPolicy = .keepRemote

	public init(automaticallySynchronizes: Bool = true) {
		self.automaticallySynchronizes = automaticallySynchronizes
	}

	public func pullRevisions(since knowledgeVector: OCKRevisionRecord.KnowledgeVector, mergeRevision: @escaping (OCKRevisionRecord, @escaping (Error?) -> Void) -> Void, completion: @escaping (Error?) -> Void) {
		AlfredClient.client.getCarePlan { result in
			switch result {
			case .failure(let error):
				completion(error)
			case .success(let carePlanResponses):
				let vectorClock = carePlanResponses.vectorClock
				guard let backendRevision = vectorClock["backend"] else {
					let revision = OCKRevisionRecord(entities: [], knowledgeVector: .init())
					mergeRevision(revision) { error in
						completion(error)
					}
					return
				}
				ALog.info("\(knowledgeVector), backend revision \(backendRevision)")
				completion(nil)
			}
		}
	}

	public func pushRevisions(deviceRevision: OCKRevisionRecord, overwriteRemote: Bool, completion: @escaping (Error?) -> Void) {
		ALog.info("pushRevisions: Device Revision: \(deviceRevision), overwrite Remote: \(overwriteRemote)")
		completion(OCKStoreError.remoteSynchronizationFailed(reason: "Backend not setup yet"))
	}

	public func chooseConflictResolutionPolicy(_ conflict: OCKMergeConflictDescription, completion: @escaping (OCKMergeConflictResolutionPolicy) -> Void) {
		completion(mergeConflictResolutionPolicy)
	}
}
