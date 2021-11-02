//
//  TaskHeaderView+Update.swift
//  Allie
//
//  Created by Waqar Malik on 10/26/21.
//

import CareKitStore
import CareKitUI
import HealthKit
import UIKit

extension TaskHeaderView {
	func updateWith(task: OCKAnyTask?, event: OCKAnyEvent?, animated: Bool) {
		guard let event = event else {
			clearView(animated: animated)
			return
		}

		let task = task ?? event.task
		textLabel.text = task.title
		detailTextLabel.text = task.instructions ?? ScheduleUtility.scheduleLabel(for: event)
		let quantityIdentifier = (task as? OCKHealthKitTask)?.healthKitLinkage.quantityIdentifier
		if let dataType = quantityIdentifier?.dataType {
			imageView.image = dataType.image
		} else if let identifier = task.groupIdentifierType, let icon = identifier.icon {
			imageView.image = icon
		}
		updateAccessibilityLabel()
	}

	func updateWith(events: [OCKAnyEvent]?, animated: Bool) {
		guard let events = events, !events.isEmpty else {
			clearView(animated: animated)
			return
		}

		let task = events.first!.task
		textLabel.text = task.title
		detailTextLabel.text = task.instructions ?? ScheduleUtility.scheduleLabel(for: events)
		if let dataType = (task as? OCKHealthKitTask)?.healthKitLinkage.quantityIdentifier.dataType {
			imageView.image = dataType.image
		}
		updateAccessibilityLabel()
	}

	func clearView(animated: Bool) {
		[textLabel, detailTextLabel].forEach { $0.text = nil }
		imageView.image = UIImage(named: "icon-empty")
		accessibilityLabel = nil
	}

	func updateAccessibilityLabel() {
		accessibilityLabel = "\(textLabel.text ?? ""), \(detailTextLabel.text ?? "")"
	}
}
