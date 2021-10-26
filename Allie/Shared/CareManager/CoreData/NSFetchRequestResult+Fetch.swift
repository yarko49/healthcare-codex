//
//  NSFetchRequestResult+Fetch.swift
//  Allie
//
//  Created by Waqar Malik on 10/22/21.
//

import CoreData
import Foundation

extension NSFetchRequestResult where Self: NSManagedObject {
	static func fetchRequestForEntity(inContext context: NSManagedObjectContext) -> NSFetchRequest<Self> {
		let fetchRequest = NSFetchRequest<Self>()
		fetchRequest.entity = entity()
		return fetchRequest
	}

	static func findFirst(inContext context: NSManagedObjectContext, predicate: NSPredicate? = nil) throws -> Self? {
		let fetchRequest = fetchRequestForEntity(inContext: context)
		fetchRequest.predicate = predicate
		fetchRequest.fetchLimit = 1
		fetchRequest.returnsObjectsAsFaults = false
		fetchRequest.fetchBatchSize = 1
		return try context.fetch(fetchRequest).first
	}

	static func all(inContext context: NSManagedObjectContext, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Self] {
		let fetchRequest = fetchRequestForEntity(inContext: context)
		fetchRequest.sortDescriptors = sortDescriptors
		fetchRequest.predicate = predicate
		return try context.fetch(fetchRequest)
	}

	static func count(inContext context: NSManagedObjectContext, predicate: NSPredicate? = nil) throws -> Int {
		let fetchReqeust = fetchRequestForEntity(inContext: context)
		fetchReqeust.includesSubentities = false
		fetchReqeust.predicate = predicate
		return try context.count(for: fetchReqeust)
	}

	static func removeAll(inContext context: NSManagedObjectContext) throws {
		let fetchRequest = fetchRequestForEntity(inContext: context)
		try removeAllObjectsReturnedBy(fetchRequest: fetchRequest, inContext: context)
	}

	static func removeAll(inContext context: NSManagedObjectContext, except toKeep: [Self]) throws {
		let fetchRequest = fetchRequestForEntity(inContext: context)
		fetchRequest.predicate = NSPredicate(format: "NOT (self IN %@)", toKeep)
		try removeAllObjectsReturnedBy(fetchRequest: fetchRequest, inContext: context)
	}

	private static func removeAllObjectsReturnedBy(fetchRequest: NSFetchRequest<Self>, inContext context: NSManagedObjectContext) throws {
		fetchRequest.includesPropertyValues = false
		fetchRequest.includesSubentities = false
		try context.fetch(fetchRequest).lazy.forEach(context.delete(_:))
	}
}
