//
//  ConversationsManager.swift
//  Allie
//
//  Created by Waqar Malik on 6/17/21.
//

import Combine
import TwilioConversationsClient
import UIKit

protocol ConversationsManagerDelegate: AnyObject {
	func reloadMessages()
	func receivedNewMessage()
	func displayStatusMessage(_ statusMessage: String)
	func displayErrorMessage(_ errorMessage: String)
}

class ConversationsManager: NSObject {
	private enum Constants {
		static let apiBaseURLString = "https://conversations.twilio.com/v1"
		static let uniqueConversationName = "general"
		static let messagesDownloadPageSize: UInt = 100
	}

	private(set) var cancellables: Set<AnyCancellable> = []
	weak var delegate: ConversationsManagerDelegate?
	private var client: TwilioConversationsClient?
	private var conversation: TCHConversation?
	private(set) var messages: [TCHMessage] = []

	private func refreshAccessToken() {
		APIClient.shared.getConservations()
			.sink { result in
				if case .failure(let error) = result {
					ALog.error("Error retrieving token \(error.localizedDescription)")
				}
			} receiveValue: { [weak self] conversations in
				self?.client?.updateToken(conversations.tokens.accessToken, completion: { result in
					if result.isSuccessful {
						ALog.info("Access token refreshed")
					} else {
						ALog.error("Unable to refresh access token")
					}
				})
			}.store(in: &cancellables)
	}

	func send(message: String, completion: @escaping (TCHResult, TCHMessage?) -> Void) {
		let messageOptions = TCHMessageOptions().withBody(message)
		conversation?.sendMessage(with: messageOptions, completion: { result, message in
			completion(result, message)
		})
	}

	func loginFromServer(identity: String, completion: @escaping (Bool) -> Void) {
		APIClient.shared.getConservations()
			.sink { result in
				if case .failure(let error) = result {
					ALog.error("Error retrieving token \(error.localizedDescription)")
					completion(false)
				}
			} receiveValue: { [weak self] conversations in
				TwilioConversationsClient.conversationsClient(withToken: conversations.tokens.accessToken, properties: nil, delegate: self) { result, client in
					self?.client = client
					completion(result.isSuccessful)
				}
			}.store(in: &cancellables)
	}

	func login(accessToken token: String) {
		TwilioConversationsClient.conversationsClient(withToken: token, properties: nil, delegate: self) { [weak self] result, client in
			self?.client = client
			ALog.info("Login Result \(result)")
		}
	}

	func shutdown() {
		guard let client = client else {
			return
		}
		client.delegate = nil
		client.shutdown()
		self.client = nil
	}

	private func createConversation(uniqueName: String, completion: @escaping (Bool, TCHConversation?) -> Void) {
		guard let client = client else {
			return
		}
		// Create the conversation if it hasn't been created yet
		let options: [String: Any] = [TCHConversationOptionUniqueName: uniqueName]
		client.createConversation(options: options) { result, conversation in
			if result.isSuccessful {
				ALog.info("Conversation created.")
			} else {
				ALog.error("Conversation NOT created \(result.error?.localizedDescription ?? "")", error: result.error)
			}
			completion(result.isSuccessful, conversation)
		}
	}

	private func checkConversationCreation(completion: @escaping (TCHResult?, TCHConversation?) -> Void) {
		guard let client = client else {
			return
		}
		client.conversation(withSidOrUniqueName: Constants.uniqueConversationName) { result, conversation in
			completion(result, conversation)
		}
		// let myConversations = client.myConversations()
		// completion(TCHResult(), client.myConversations()?.first)
	}

	private func join(conversation: TCHConversation) {
		self.conversation = conversation
		if conversation.status == .joined {
			ALog.info("Current user already exists in conversation")
			loadPreviousMessages(for: conversation)
		} else {
			conversation.join(completion: { result in
				ALog.info("Result of conversation join: \(result.resultText ?? "No Result")")
				if result.isSuccessful {
					self.loadPreviousMessages(for: conversation)
				}
			})
		}
	}

	private func loadPreviousMessages(for conversation: TCHConversation) {
		conversation.getLastMessages(withCount: Constants.messagesDownloadPageSize) { result, messages in
			if let messages = messages, result.isSuccessful {
				self.messages = messages
				DispatchQueue.main.async {
					self.delegate?.reloadMessages()
				}
			}
		}
	}
}

extension ConversationsManager: TwilioConversationsClientDelegate {
	func conversationsClient(_ client: TwilioConversationsClient, connectionStateUpdated state: TCHClientConnectionState) {
		ALog.trace("connectionStateUpdated:")
	}

	func conversationsClientTokenWillExpire(_ client: TwilioConversationsClient) {
		ALog.info("Access token will expire.")
		refreshAccessToken()
	}

	func conversationsClientTokenExpired(_ client: TwilioConversationsClient) {
		ALog.info("Access token expired.")
		refreshAccessToken()
	}

	func conversationsClient(_ client: TwilioConversationsClient, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
		guard status == .completed else {
			return
		}

		checkConversationCreation { _, conversation in
			if let conversation = conversation {
				self.join(conversation: conversation)
			} else {
				self.createConversation(uniqueName: Constants.uniqueConversationName) { success, conversation in
					if success, let conversation = conversation {
						self.join(conversation: conversation)
					}
				}
			}
		}
	}

	func conversationsClient(_ client: TwilioConversationsClient, conversationAdded conversation: TCHConversation) {
		ALog.trace("conversationAdded:")
	}

	func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, updated: TCHConversationUpdate) {
		ALog.trace("conversation:updated:")
	}

	func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, synchronizationStatusUpdated status: TCHConversationSynchronizationStatus) {
		ALog.trace("conversation:synchronizationStatusUpdated:")
	}

	func conversationsClient(_ client: TwilioConversationsClient, conversationDeleted conversation: TCHConversation) {
		ALog.trace("conversation:conversationDeleted:")
	}

	func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participantJoined participant: TCHParticipant) {
		ALog.trace("conversation:participantJoined:")
	}

	func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participant: TCHParticipant, updated: TCHParticipantUpdate) {
		ALog.trace("conversation:participant:updated:")
	}

	func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participantLeft participant: TCHParticipant) {
		ALog.trace("conversation:participantLeft:")
	}

	// Called whenever a conversation we've joined receives a new message
	func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, messageAdded message: TCHMessage) {
		messages.append(message)
		// Changes to the delegate should occur on the UI thread
		DispatchQueue.main.async {
			if let delegate = self.delegate {
				delegate.reloadMessages()
				delegate.receivedNewMessage()
			}
		}
	}

	func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, message: TCHMessage, updated: TCHMessageUpdate) {
		ALog.trace("conversation:message:updated:")
	}

	func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, messageDeleted message: TCHMessage) {
		ALog.trace("conversation:messageDeleted:")
	}

	func conversationsClient(_ client: TwilioConversationsClient, errorReceived error: TCHError) {
		ALog.trace("errorReceived:")
	}

	func conversationsClient(_ client: TwilioConversationsClient, typingStartedOn conversation: TCHConversation, participant: TCHParticipant) {
		ALog.trace("typingStartedOn:participant:")
	}

	func conversationsClient(_ client: TwilioConversationsClient, typingEndedOn conversation: TCHConversation, participant: TCHParticipant) {
		ALog.trace("typingEndedOn:participant:")
	}

	func conversationsClient(_ client: TwilioConversationsClient, notificationNewMessageReceivedForConversationSid conversationSid: String, messageIndex: UInt) {
		ALog.trace("notificationNewMessageReceivedForConversationSid:messageIndex:")
	}

	func conversationsClient(_ client: TwilioConversationsClient, notificationAddedToConversationWithSid conversationSid: String) {
		ALog.trace("notificationAddedToConversationWithSid:")
	}

	func conversationsClient(_ client: TwilioConversationsClient, notificationRemovedFromConversationWithSid conversationSid: String) {
		ALog.trace("notificationRemovedFromConversationWithSid:")
	}

	func conversationsClient(_ client: TwilioConversationsClient, notificationUpdatedBadgeCount badgeCount: UInt) {
		ALog.trace("notificationUpdatedBadgeCount:")
	}

	func conversationsClient(_ client: TwilioConversationsClient, user: TCHUser, updated: TCHUserUpdate) {
		ALog.trace("user:updated:")
	}

	func conversationsClient(_ client: TwilioConversationsClient, userSubscribed user: TCHUser) {
		ALog.trace("userSubscribed:")
	}

	func conversationsClient(_ client: TwilioConversationsClient, userUnsubscribed user: TCHUser) {
		ALog.trace("userUnsubscribed:")
	}
}
