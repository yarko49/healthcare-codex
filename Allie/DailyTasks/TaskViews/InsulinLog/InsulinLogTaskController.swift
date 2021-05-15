//
//  InsulinTaskLogController.swift
//  Allie
//
//  Created by Waqar Malik on 5/9/21.
//

import CareKit
import CareKitStore
import Combine
import Foundation

class InsulinLogTaskController: OCKTaskController {
	// This function gets called as a result of the delegate call in the view.
	override func setEvent(atIndexPath indexPath: IndexPath, isComplete: Bool, completion: ((Result<OCKAnyOutcome, Error>) -> Void)?) {
		super.setEvent(atIndexPath: indexPath, isComplete: isComplete, completion: completion)
		ALog.info("setEvent:atIndexPath:isComplete:completion:")
	}
}
