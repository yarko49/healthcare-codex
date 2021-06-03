//
//  FileManager+Documents.swift
//  Allie
//
//  Created by Waqar Malik on 5/30/21.
//

import Foundation

extension FileManager {
	func documentsFileURL(patientId: String, carePlanId: String, taskId: String, name: String) -> URL? {
		guard var path = urls(for: .documentDirectory, in: .userDomainMask).first else {
			return nil
		}
		[patientId, carePlanId, taskId, name].forEach { component in
			path.appendPathComponent(component)
		}
		return path
	}
}
