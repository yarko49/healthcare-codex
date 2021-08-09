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
	override func outcomeStore(_ store: OCKAnyReadOnlyOutcomeStore, didDeleteOutcomes outcomes: [OCKAnyOutcome]) {
		super.outcomeStore(store, didDeleteOutcomes: outcomes)
		CareManager.shared.upload(outcomes: outcomes)
	}
}
