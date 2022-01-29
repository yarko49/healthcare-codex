//
//  PairingItem+BloodPressure.swift
//  Allie
//
//  Created by Waqar Malik on 1/13/22.
//

import Foundation

extension PairingItem {
	static var bloodPressureItems: [PairingItem] = [PairingItem(id: "one", imageName: "", title: NSLocalizedString("BT_STEP_ONE.title", comment: "Step 1."), message: NSLocalizedString("BPM_STEP_ONE.message", comment: "Step 1 Message")),
	                                                PairingItem(id: "two", imageName: "", title: NSLocalizedString("BT_STEP_TWO.title", comment: "Step 2."), message: NSLocalizedString("BPM_STEP_TWO.message", comment: "Step 2 Message")),
	                                                PairingItem(id: "three", imageName: "", title: NSLocalizedString("BT_STEP_THREE.title", comment: "Step 3."), message: NSLocalizedString("BPM_STEP_THREE.message", comment: "Step 3 Message"))]
}
