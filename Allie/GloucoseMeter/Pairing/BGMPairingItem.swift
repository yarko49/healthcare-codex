//
//  BGMPairingItem.swift
//  Allie
//
//  Created by Waqar Malik on 8/23/21.
//

import Foundation

struct BGMPairingItem: Hashable, Identifiable {
	let id: String
	let imageName: String
	let title: String
	let message: String?
}

extension BGMPairingItem {
	static var items: [BGMPairingItem] = [BGMPairingItem(id: "one", imageName: "contour1", title: NSLocalizedString("STEP_ONE.title", comment: "Step 1."), message: NSLocalizedString("STEP_ONE.message", comment: "Step 1 Message")),
	                                      BGMPairingItem(id: "two", imageName: "contour2", title: NSLocalizedString("STEP_TWO.title", comment: "Step 2."), message: NSLocalizedString("STEP_TWO.message", comment: "Step 2 Message")),
	                                      BGMPairingItem(id: "three", imageName: "contour3", title: NSLocalizedString("STEP_THREE.title", comment: "Step 3."), message: NSLocalizedString("STEP_THREE.message", comment: "Step 3 Message"))]

	static var successItem: BGMPairingItem {
		BGMPairingItem(id: "success", imageName: "successIcon", title: NSLocalizedString("STEP_SUCCESS.title", comment: "Step Success."), message: NSLocalizedString("STEP_SUCCESS.message", comment: "Sucess Message"))
	}

	static var failureItem: BGMPairingItem {
		BGMPairingItem(id: "failure", imageName: "successIcon", title: NSLocalizedString("STEP_FAILURE.title", comment: "Step Fail."), message: NSLocalizedString("STEP_FAILURE.message", comment: "Failure Message"))
	}
}
