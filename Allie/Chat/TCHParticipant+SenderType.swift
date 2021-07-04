//
//  TCHParticipant+SenderType.swift
//  Allie
//
//  Created by Waqar Malik on 6/27/21.
//

import Foundation
import MessageKit
import TwilioConversationsClient

extension TCHParticipant: SenderType {
	public var senderId: String {
		identity ?? UUID().uuidString
	}

	public var displayName: String {
		identity == CareManager.shared.patient?.id ? (CareManager.shared.patient?.displayName ?? "Local User") : "Remote User"
	}
}
