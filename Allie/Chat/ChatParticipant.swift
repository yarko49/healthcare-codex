//
//  ChatParticipant.swift
//  Allie
//
//  Created by Waqar Malik on 7/3/21.
//

import CareModel
import Foundation
import MessageKit

// Hack to make missing chat participant, sender and local
struct ChatParticipant: Codable, Identifiable {
	let id: String
	let name: String
}

extension ChatParticipant {
	init(patient: CHPatient) {
		self.id = patient.id
		self.name = patient.displayName
	}

	init(name: String = "Organization") {
		self.id = UUID().uuidString
		self.name = name
	}
}

extension ChatParticipant: SenderType {
	var senderId: String {
		id
	}

	var displayName: String {
		name
	}
}
