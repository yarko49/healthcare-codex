//
//  CHPatient+SenderType.swift
//  Allie
//
//  Created by Waqar Malik on 6/27/21.
//

import Foundation
import MessageKit

extension CHPatient: SenderType {
	public var senderId: String {
		id
	}

	public var displayName: String {
		name.fullName ?? "Patient"
	}
}
