//
//  AlliePatient+Keychain.swift
//  Allie
//
//  Created by Waqar Malik on 3/28/21.
//

import CareKitStore
import Foundation

extension Keychain {
	static func save(patient: AlliePatient?) {
		guard let patient = patient else {
			return
		}
		save(value: patient, forKey: patient.id)
	}

	static func readPatient(forKey key: String) -> AlliePatient? {
		read(forKey: key)
	}

	static func read<T: Decodable>(forKey key: String) -> T? {
		guard let data = Keychain.read(dataForKey: key) else {
			return nil
		}
		do {
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			let value = try decoder.decode(T.self, from: data)
			return value
		} catch {
			ALog.error("\(error.localizedDescription)")
			return nil
		}
	}

	static func save<T: Encodable>(value: T?, forKey key: String) {
		guard let value = value else {
			delete(valueForKey: key)
			return
		}
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		do {
			let data = try encoder.encode(value)
			Keychain.store(data: data, forKey: key)
		} catch {
			ALog.error("\(error.localizedDescription)")
		}
	}
}
