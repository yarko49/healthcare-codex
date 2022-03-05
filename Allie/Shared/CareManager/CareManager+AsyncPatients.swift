//
//  CareManager+AsyncPatients.swift
//  Allie
//
//  Created by Waqar Malik on 2/24/22.
//

import CareKitStore
import CareModel
import Foundation

extension CareManager {
	func process(patient: CHPatient) async throws -> CHPatient {
		var updatePatient = patient
		let ockPatient = OCKPatient(patient: patient)
		do {
			let existingPatient = try await store.fetchPatient(withID: updatePatient.id)
			let updated = existingPatient.merged(newPatient: ockPatient)
			let newPatient = try await store.updatePatient(updated)
			updatePatient.uuid = newPatient.uuid
		} catch {
			let newPatient = try await store.addPatient(ockPatient)
			updatePatient.uuid = newPatient.uuid
		}
		return updatePatient
	}

	func loadPatient() async throws -> OCKPatient {
		let patients = try await store.fetchPatients(query: OCKPatientQuery(for: Date()))
		let sorted = patients.sorted { lhs, rhs in
			guard let ldate = lhs.updatedDate, let rdate = rhs.updatedDate else {
				return false
			}
			return ldate < rdate
		}
		guard let lastItem = sorted.last else {
			throw OCKStoreError.fetchFailed(reason: "No patients in the store")
		}
		return lastItem
	}

	func findPatient(identifier: String) async throws -> OCKPatient {
		try await store.fetchPatient(withID: identifier)
	}

	func findOrCreate(user: RemoteUser) async throws -> OCKPatient {
		do {
			let patient = try await findPatient(identifier: user.uid)
			return patient
		} catch {
			let patient = try OCKPatient(remoteUser: user)
			return try await store.addPatient(patient)
		}
	}

	func deleteAllPatients() async throws {
		let dateInterval = DateInterval(start: Date.distantPast, end: Date.distantFuture)
		let patientsQuery = OCKPatientQuery(dateInterval: dateInterval)
		let allPatients = try await store.fetchAnyPatients(query: patientsQuery)
		if !allPatients.isEmpty {
			_ = try await store.deleteAnyPatients(allPatients)
		}
	}

	func deletePatients(exclude: [String]) async throws {
		let dateInterval = DateInterval(start: Date.distantPast, end: Date.distantFuture)
		let patientsQuery = OCKPatientQuery(dateInterval: dateInterval)
		let allPatients = try await store.fetchAnyPatients(query: patientsQuery)
		let filtered = allPatients.filter { patient in
			!exclude.contains(patient.id)
		}

		guard !filtered.isEmpty else {
			return
		}
		_ = try await store.deleteAnyPatients(filtered)
	}
}
