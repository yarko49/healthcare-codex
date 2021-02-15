//
//  OCKOutcomeValue+Conversion.swift
//  Allie
//
//  Created by Waqar Malik on 12/8/20.
//

import CareKitStore
import Foundation

extension OCKOutcomeValue {
	init(outcomeValue: OutcomeValue) {
		self.init(outcomeValue.value, units: outcomeValue.units)
		self.index = outcomeValue.index
		self.remoteID = outcomeValue.remoteId
		self.units = outcomeValue.units
		self.source = outcomeValue.source
		self.groupIdentifier = outcomeValue.groupIdentifier
		self.timezone = outcomeValue.timezone
		self.kind = outcomeValue.kind
		self.tags = outcomeValue.tags
		self.userInfo = outcomeValue.userInfo
		self.asset = outcomeValue.asset
		self.notes = outcomeValue.notes?.compactMap { (note) -> OCKNote? in
			OCKNote(note: note)
		}
	}
}

extension OutcomeValue {
	init(ockOutcomeValue: OCKOutcomeValue) {
		self.init(ockOutcomeValue.value)
		self.id = ockOutcomeValue.remoteID
		self.type = ockOutcomeValue.type
		self.index = ockOutcomeValue.index ?? 0
		self.remoteId = ockOutcomeValue.remoteID
		self.units = ockOutcomeValue.units
		self.source = ockOutcomeValue.source
		self.groupIdentifier = ockOutcomeValue.groupIdentifier
		self.timezone = ockOutcomeValue.timezone
		self.kind = ockOutcomeValue.kind
		self.tags = ockOutcomeValue.tags
		self.userInfo = ockOutcomeValue.userInfo
		self.asset = ockOutcomeValue.asset
		self.notes = ockOutcomeValue.notes?.compactMap { (ockNote) -> Note? in
			Note(ockNote: ockNote)
		}
	}
}
