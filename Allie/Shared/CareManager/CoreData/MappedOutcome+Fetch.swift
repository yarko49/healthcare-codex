//
//  Outcome+Fetch.swift
//  Allie
//
//  Created by Waqar Malik on 10/22/21.
//

import CareKitStore
import CareModel
import CoreData
import Foundation
import HealthKit

extension MappedOutcome {
	var outcome: CHOutcome? {
		get {
			do {
				guard let data = value else {
					return nil
				}
				return try JSONDecoder().decode(CHOutcome.self, from: data)
			} catch {
				ALog.error("Unable to get outcome", error: error)
				return nil
			}
		}
		set {
			do {
				guard let outcome = newValue else {
					value = nil
					return
				}
				let data = try JSONEncoder().encode(outcome)
				value = data
			} catch {
				ALog.error("Unable to set outcome", error: error)
			}
		}
	}
}

extension MappedOutcome {
	convenience init(outcome: CHOutcome, insertInto context: NSManagedObjectContext) {
		self.init(entity: Self.entity(), insertInto: context)
		updateProperies(outcome: outcome)
	}

	func updateProperies(outcome: CHOutcome) {
		uuid = outcome.uuid
		sampleId = outcome.healthKit?.sampleUUID
		remoteId = outcome.remoteId
		taskId = outcome.taskId
		createdDate = outcome.createdDate
		updatedDate = outcome.updatedDate
		deletedDate = outcome.deletedDate
		self.outcome = outcome
	}
}

extension MappedOutcome {
	static func findFirst(inContext context: NSManagedObjectContext, sample: HKSample) throws -> Self? {
		try findFirst(inContext: context, sampleId: sample.uuid)
	}

	static func findFirst(inContext context: NSManagedObjectContext, sampleId: UUID) throws -> Self? {
		let predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(MappedOutcome.sampleId), sampleId])
		return try findFirst(inContext: context, predicate: predicate)
	}

	static func findFirst(inContext context: NSManagedObjectContext, uuid: UUID) throws -> Self? {
		let predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(MappedOutcome.uuid), uuid])
		return try findFirst(inContext: context, predicate: predicate)
	}
}
