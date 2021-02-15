//
//  CarePlanStoreManager+Debug.swift
//  Allie
//
//  Created by Waqar Malik on 1/17/21.
//

import CareKitStore
import Foundation

extension CarePlanStoreManager {
	class var sampleResponse: CarePlanResponse {
		carePlanResponse(contentsOf: "DefaultDiabetesCarePlan", withExtension: "json") ??
			CarePlanResponse(carePlans: [:], tasks: [:], vectorClock: [:])
	}

	class var samplePatient: OCKPatient {
		var name = PersonNameComponents()
		name.namePrefix = "Dr."
		name.givenName = "Ivan"
		name.familyName = "Pavlov"
		name.middleName = "Petrovich"
		name.nameSuffix = "MD"
		var patient = OCKPatient(id: "ivanplavlov", name: name)
		patient.birthday = DateComponents(year: 1849, month: 9, day: 26).date
		patient.sex = .male
		return patient
	}

	static func carePlanResponse(contentsOf name: String, withExtension: String) -> CarePlanResponse? {
		guard let fileURL = Bundle.main.url(forResource: name, withExtension: withExtension) else {
			return nil
		}
		do {
			let data = try Data(contentsOf: fileURL)
			let carePlanResponse = try CHJSONDecoder().decode(CarePlanResponse.self, from: data)
			return carePlanResponse
		} catch {
			ALog.info("\(error.localizedDescription)")
			return nil
		}
	}

	static func carePlanResponse(name: String, withExtension: String, completion: OCKResultClosure<CarePlanResponse>?) {
		guard let carePlanResponse = self.carePlanResponse(contentsOf: name, withExtension: withExtension) else {
			completion?(.failure(.fetchFailed(reason: "File does not exists \(name).\(withExtension)")))
			return
		}
		completion?(.success(carePlanResponse))
	}
}
