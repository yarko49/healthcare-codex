//
//  AlliePatient+Keychain.swift
//  Allie
//
//  Created by Waqar Malik on 3/28/21.
//

import Foundation

extension Keychain {
	static func save(patient: AlliePatient) {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		do {
			let data = try encoder.encode(patient)
			Keychain.store(data: data, forKey: patient.id)
		} catch {
			ALog.error("\(error.localizedDescription)")
		}
	}

	static func readPatient(forKey key: String) -> AlliePatient? {
		guard let data = Keychain.read(dataForKey: key) else {
			return nil
		}
		do {
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			let patient = try decoder.decode(AlliePatient.self, from: data)
			return patient
		} catch {
			ALog.error("\(error.localizedDescription)")
			return nil
		}
	}
}
