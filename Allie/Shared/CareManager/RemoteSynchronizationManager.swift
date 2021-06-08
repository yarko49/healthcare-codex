//
//  RemoteSynchronizationManager.swift
//  Allie
//
//  Created by Waqar Malik on 11/23/20.
//

import CareKitStore
import Combine
import Foundation

public final class RemoteSynchronizationManager: OCKRemoteSynchronizable {
	public weak var delegate: OCKRemoteSynchronizationDelegate?
	public var automaticallySynchronizes: Bool
	private var cancellables: Set<AnyCancellable> = []

	public init(automaticallySynchronizes: Bool = true) {
		self.automaticallySynchronizes = automaticallySynchronizes
	}

	public func pullRevisions(since knowledgeVector: OCKRevisionRecord.KnowledgeVector, mergeRevision: @escaping (OCKRevisionRecord) -> Void, completion: @escaping (Error?) -> Void) {
		APIClient.shared.getCarePlan(option: .carePlan)
			.sink { completionResult in
				if case .failure(let error) = completionResult {
					completion(error)
				}
			} receiveValue: { response in
				let vectorClock = response.vectorClock
				ALog.info("\(knowledgeVector), backend revision \(vectorClock)")
				completion(nil)
			}.store(in: &cancellables)
	}

	public func pushRevisions(deviceRevision: OCKRevisionRecord, completion: @escaping (Error?) -> Void) {
		ALog.info("pushRevisions: Device Revision: \(deviceRevision)")
		completion(nil)
	}

	public func chooseConflictResolution(conflicts: [OCKEntity], completion: @escaping OCKResultClosure<OCKEntity>) {
		completion(.failure(.remoteSynchronizationFailed(reason: "Missing data")))
	}
}
