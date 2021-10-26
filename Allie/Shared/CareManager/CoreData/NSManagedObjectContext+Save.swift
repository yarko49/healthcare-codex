//
//  NSManagedObjectContext+Save.swift
//  Allie
//
//  Created by Waqar Malik on 10/22/21.
//

import CoreData
import Foundation
extension NSManagedObjectContext {
	func saveContextAndWait() throws {
		switch concurrencyType {
		case .confinementConcurrencyType:
			try sharedSaveFlow()
		case .mainQueueConcurrencyType, .privateQueueConcurrencyType:
			try performAndWaitOrThrow(sharedSaveFlow)
		@unknown default:
			throw AllieError.forbidden("Unkown Concurrency Type")
		}
	}

	func saveContext(_ completion: AllieResultCompletion<Bool>? = nil) {
		func saveFlow() {
			do {
				try sharedSaveFlow()
				completion?(.success(true))
			} catch let saveError {
				completion?(.failure(saveError))
			}
		}

		switch concurrencyType {
		case .confinementConcurrencyType:
			saveFlow()
		case .privateQueueConcurrencyType, .mainQueueConcurrencyType:
			perform(saveFlow)
		@unknown default:
			completion?(.failure(AllieError.forbidden("Unkown Concurrency Type")))
		}
	}

	func saveContextToStoreAndWait() throws {
		func saveFlow() throws {
			try sharedSaveFlow()
			if let parentContext = parent {
				try parentContext.saveContextToStoreAndWait()
			}
		}

		switch concurrencyType {
		case .confinementConcurrencyType:
			try saveFlow()
		case .mainQueueConcurrencyType, .privateQueueConcurrencyType:
			try performAndWaitOrThrow(saveFlow)
		@unknown default:
			throw AllieError.forbidden("Unkown Concurrency Type")
		}
	}

	func saveContextToStore(_ completion: AllieResultCompletion<Bool>? = nil) {
		func saveFlow() {
			do {
				try sharedSaveFlow()
				if let parentContext = parent {
					parentContext.saveContextToStore(completion)
				} else {
					completion?(.success(true))
				}
			} catch let saveError {
				completion?(.failure(saveError))
			}
		}

		switch concurrencyType {
		case .confinementConcurrencyType:
			saveFlow()
		case .privateQueueConcurrencyType, .mainQueueConcurrencyType:
			perform(saveFlow)
		@unknown default:
			completion?(.failure(AllieError.forbidden("Unkown Concurrency Type")))
		}
	}

	func sharedSaveFlow() throws {
		guard hasChanges else {
			return
		}

		try save()
	}

	func performAndWaitOrThrow<ResultType>(_ body: () throws -> ResultType) rethrows -> ResultType {
		try withoutActuallyEscaping(body) { work in
			var result: ResultType!
			var resultError: Error?

			performAndWait {
				do {
					result = try work()
				} catch {
					resultError = error
				}
			}

			if let error = resultError {
				throw error
			} else {
				return result
			}
		}
	}
}
