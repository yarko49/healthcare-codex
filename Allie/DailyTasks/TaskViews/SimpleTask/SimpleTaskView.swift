//
//  SimpleTaskView.swift
//  Allie
//
//  Created by Waqar Malik on 10/18/21.
//

import CareKitStore
import CareKitUI
import Foundation

class SimpleTaskView: OCKSimpleTaskView {
	func updateWith(task: OCKAnyTask?, event: OCKAnyEvent?, animated: Bool) {
		headerView.updateWith(event: event, animated: animated)
		guard let event = event else {
			clearView(animated: animated)
			return
		}
		headerView.detailLabel.text = task?.instructions ?? event.task.instructions ?? ScheduleUtility.scheduleLabel(for: event)
		let isComplete = event.outcome != nil
		completionButton.isSelected = isComplete
		accessibilityLabel = (headerView.titleLabel.text ?? "") + ", " + (headerView.detailLabel.text ?? "")
		accessibilityValue = loc(isComplete ? "COMPLETED" : "INCOMPLETE")
	}

	func clearView(animated: Bool) {
		completionButton.setSelected(false, animated: animated)
		accessibilityValue = nil
	}
}
