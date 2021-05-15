//
//  OCKTaskEvents+Extension.swift
//  Allie
//
//  Created by Waqar Malik on 5/10/21.
//

import CareKit
import CareKitStore
import Foundation

extension OCKTaskEvents {
	var ch_firstEventTitle: String {
		first?.first?.task.title ?? ""
	}

	var ch_firstTaskInstructions: String? {
		first?.first?.task.instructions
	}

	var ch_firstEventDetail: String? {
		ScheduleUtility.scheduleLabel(for: first?.first)
	}

	var ch_isFirstEventComplete: Bool {
		first?.first?.outcome != nil
	}
}
