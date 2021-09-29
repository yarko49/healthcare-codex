//
//  CHSynchronizedStoreManager.swift
//  Allie
//
//  Created by Waqar Malik on 8/5/21.
//

import CareKit
import CareKitStore
import Foundation

class CHSynchronizedStoreManager: OCKSynchronizedStoreManager {
	@Injected(\.careManager) var careManager: CareManager
	override func outcomeStore(_ store: OCKAnyReadOnlyOutcomeStore, didDeleteOutcomes outcomes: [OCKAnyOutcome]) {
		super.outcomeStore(store, didDeleteOutcomes: outcomes)
		careManager.upload(outcomes: outcomes)
	}

	override func outcomeStore(_ store: OCKAnyReadOnlyOutcomeStore, didUpdateOutcomes outcomes: [OCKAnyOutcome]) {
		super.outcomeStore(store, didUpdateOutcomes: outcomes)
		ALog.info("Did update outcomes \(outcomes.count)")
	}

	override func outcomeStore(_ store: OCKAnyReadOnlyOutcomeStore, didAddOutcomes outcomes: [OCKAnyOutcome]) {
		super.outcomeStore(store, didAddOutcomes: outcomes)
		ALog.info("Did add Outcomes \(outcomes.count)")
	}
}
