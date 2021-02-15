//
//  CodexResource+PatientResource.swift
//  Allie
//
//  Created by Waqar Malik on 1/12/21.
//

import CareKitStore
import Foundation

protocol PatientName {
	var use: String? { get }
	var family: String? { get }
	var given: [String]? { get }
}

protocol PatientResource {
	var id: String? { get }
	var effectiveDate: Date? { get }
	var birthday: Date? { get }
	var gender: String? { get }
	var nameComponents: PatientName? { get }
	var lastUpdated: String? { get }
	var versionId: String? { get }
}

extension CodexResource: PatientResource {
	var effectiveDate: Date? {
		guard let dateString = effectiveDateTime else {
			return nil
		}

		return DateFormatter.rfc3339.date(from: dateString)
	}

	var birthday: Date? {
		guard let dateString = birthDate else {
			return nil
		}

		return DateFormatter.yyyyMMdd.date(from: dateString)
	}

	var nameComponents: PatientName? {
		name?.first
	}

	var lastUpdated: String? {
		meta?.lastUpdated
	}

	var versionId: String? {
		meta?.versionID
	}
}

extension ResourceName: PatientName {}
