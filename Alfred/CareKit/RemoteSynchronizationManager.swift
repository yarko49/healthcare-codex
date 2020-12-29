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

	public init(automaticallySynchronizes: Bool = true) {
		self.automaticallySynchronizes = automaticallySynchronizes
	}

	public func pullRevisions(since knowledgeVector: OCKRevisionRecord.KnowledgeVector, mergeRevision: @escaping (OCKRevisionRecord, @escaping (Error?) -> Void) -> Void, completion: @escaping (Error?) -> Void) {
		completion(nil)
	}

	public func pushRevisions(deviceRevision: OCKRevisionRecord, overwriteRemote: Bool, completion: @escaping (Error?) -> Void) {
		completion(nil)
	}

	public func chooseConflictResolutionPolicy(_ conflict: OCKMergeConflictDescription, completion: @escaping (OCKMergeConflictResolutionPolicy) -> Void) {
		completion(.abortMerge)
	}
}
