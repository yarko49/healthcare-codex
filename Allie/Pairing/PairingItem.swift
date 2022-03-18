//
//  PairingItem.swift
//  Allie
//
//  Created by Waqar Malik on 8/23/21.
//

import Foundation

struct PairingItem: Hashable, Identifiable {
	let id: String
	let imageName: String
	let title: String
	let message: String?
}

extension PairingItem {
	static var successItem: PairingItem {
		PairingItem(id: "success", imageName: "icon-pairing-success", title: NSLocalizedString("STEP_SUCCESS.title", comment: "Step Success."), message: NSLocalizedString("STEP_SUCCESS.message", comment: "Sucess Message"))
	}

	static var failureItem: PairingItem {
		PairingItem(id: "failure", imageName: "icon-pairing-unsuccessfull", title: NSLocalizedString("STEP_FAILURE.title", comment: "Step Fail."), message: NSLocalizedString("STEP_FAILURE.message", comment: "Failure Message"))
	}
}
