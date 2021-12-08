//
//  CoreDataManager.swift
//  Allie
//
//  Created by Waqar Malik on 10/22/21.
//

import CoreData
import Foundation

class CoreDataManager {
	private let modelName: String

	init(modelName: String) {
		self.modelName = modelName
	}

	private lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: self.modelName)
		container.loadPersistentStores { _, error in
			if let error = error as NSError? {
				ALog.error("Unresolved error \(error), \(error.userInfo)")
			}
		}
		return container
	}()

	lazy var managedObjectContext: NSManagedObjectContext = self.persistentContainer.viewContext

	func saveContext() {
		guard managedObjectContext.hasChanges else {
			return
		}
		do {
			try managedObjectContext.save()
		} catch let error as NSError {
			ALog.error("Unresolved error \(error), \(error.userInfo)")
		}
	}

	func resetAllRecords(in entity: String) {
		let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
		let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
		do {
			try managedObjectContext.execute(deleteRequest)
			try managedObjectContext.save()
		} catch {
			print("There was an error")
		}
	}
}
