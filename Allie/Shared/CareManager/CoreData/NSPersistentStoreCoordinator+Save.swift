//
//  NSPersistentStoreCoordinator+Save.swift
//  Allie
//
//  Created by Waqar Malik on 10/22/21.
//

import CoreData
import Foundation

extension NSPersistentStoreCoordinator {
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
