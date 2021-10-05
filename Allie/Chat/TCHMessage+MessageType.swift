//
//  TCHMessage+MessageType.swift
//  Allie
//
//  Created by Waqar Malik on 6/27/21.
//

import Foundation
import MessageKit
import TwilioConversationsClient

extension TCHMessage: MessageType {
	public var sender: SenderType {
		guard let sender = participant else {
			return CHParticipant()
		}
		return sender
	}

	public var messageId: String {
		id
	}

	public var sentDate: Date {
		dateCreatedAsDate ?? Date()
	}

	public var kind: MessageKind {
		.text(body?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
	}
}
