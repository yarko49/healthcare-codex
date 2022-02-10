//
//  PairingItem+BloodGlucose.swift
//  Allie
//
//  Created by Waqar Malik on 1/12/22.
//

import Foundation

extension PairingItem {
	static var bloodGlucoseItems: [PairingItem] = [PairingItem(id: "one", imageName: "contour1", title: NSLocalizedString("BT_STEP_ONE.title", comment: "Step 1."), message: NSLocalizedString("BGM_STEP_ONE.message", comment: "Step 1 Message")),
	                                               PairingItem(id: "two", imageName: "contour2", title: NSLocalizedString("BT_STEP_TWO.title", comment: "Step 2."), message: NSLocalizedString("BGM_STEP_TWO.message", comment: "Step 2 Message")),
	                                               PairingItem(id: "three", imageName: "contour3", title: NSLocalizedString("BT_STEP_THREE.title", comment: "Step 3."), message: NSLocalizedString("BGM_STEP_THREE.message", comment: "Step 3 Message"))]
}
