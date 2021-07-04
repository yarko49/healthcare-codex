//
//  TCHMessage+Identifiable.swift
//  Allie
//
//  Created by Waqar Malik on 6/21/21.
//

import Foundation
import TwilioConversationsClient

extension TCHMessage: Identifiable {
	public var id: String {
		sid ?? ""
	}
}
