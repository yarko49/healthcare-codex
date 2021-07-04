//
//  TCHConversation+Identifiable.swift
//  Allie
//
//  Created by Waqar Malik on 6/21/21.
//

import Foundation
import TwilioConversationsClient

extension TCHConversation: Identifiable {
	public var id: String {
		sid ?? ""
	}
}
