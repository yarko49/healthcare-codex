//
//  OCKHeaderView+Update.swift
//  Allie
//
//  Created by Waqar Malik on 5/15/21.
//

import CareKit
import CareKitStore
import CareKitUI
import UIKit

extension OCKHeaderView {
	func updateWith(event: OCKAnyEvent?, animated: Bool) {
		guard let event = event else {
			clearView(animated: animated)
			return
		}

		titleLabel.text = event.task.title
		detailLabel.text = ScheduleUtility.scheduleLabel(for: event)
		updateAccessibilityLabel()
	}

	func updateWith(events: [OCKAnyEvent]?, animated: Bool) {
		guard let events = events, !events.isEmpty else {
			clearView(animated: animated)
			return
		}

		titleLabel.text = events.first!.task.title
		detailLabel.text = ScheduleUtility.scheduleLabel(for: events)
		updateAccessibilityLabel()
	}

	func clearView(animated: Bool) {
		[titleLabel, detailLabel].forEach { $0.text = nil }
		iconImageView?.image = UIImage(systemName: "person.crop.circle")
		accessibilityLabel = nil
	}

	func updateAccessibilityLabel() {
		accessibilityLabel = "\(titleLabel.text ?? ""), \(detailLabel.text ?? "")"
	}
}
