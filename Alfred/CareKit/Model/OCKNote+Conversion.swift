//
//  OCKNote+Conversion.swift
//  Alfred
//
//  Created by Waqar Malik on 12/8/20.
//

import CareKitStore
import Foundation

public extension OCKNote {
	init(note: Note) {
		self.init(author: note.author, title: note.title, content: note.content)
		self.groupIdentifier = note.groupIdentifier
		self.tags = note.tags
		self.remoteID = note.remoteId
		self.userInfo = note.userInfo
		self.source = note.source
		self.asset = note.asset
		self.notes = note.notes?.compactMap { (note) -> OCKNote? in
			OCKNote(note: note)
		}
		self.timezone = note.timezone
	}
}

public extension Note {
	init(ockNote: OCKNote) {
		self.init(id: ockNote.remoteID, timezone: ockNote.timezone)
		self.author = ockNote.author
		self.title = ockNote.title
		self.content = ockNote.content
		self.groupIdentifier = ockNote.groupIdentifier
		self.tags = ockNote.tags
		self.remoteId = ockNote.remoteID
		self.userInfo = ockNote.userInfo
		self.source = ockNote.source
		self.asset = ockNote.asset
		let newNotes: [Note]? = ockNote.notes?.compactMap { (ocknote) -> Note? in
			Note(ockNote: ocknote)
		}
		self.notes = newNotes
	}
}
