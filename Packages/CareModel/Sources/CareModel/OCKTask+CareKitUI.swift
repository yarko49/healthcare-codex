//
//  OCKTask+CareKitUI.swift
//  Allie
//
//  Created by Waqar Malik on 1/12/21.
//

import CareKitStore
import CareKitUI
import Foundation

public extension OCKTask {
	var linkItems: [CareKitUI.LinkItem]? {
		links?.compactMap { link in
			link.linkItem
		}
	}
}
