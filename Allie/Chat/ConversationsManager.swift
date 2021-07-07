//
//  ConversationsManager.swift
//  Allie
//
//  Created by Waqar Malik on 6/17/21.
//

import Combine
import MessageKit
import TwilioConversationsClient
import UIKit

protocol ConversationMessagesDelegate: AnyObject {
	func conversationsManager(_ manager: ConversationsManager, reloadMessagesFor conversation: TCHConversation)
	func conversationsManager(_ manager: ConversationsManager, didReceive message: TCHMessage, for conversation: TCHConversation)
}

enum ConversationsManagerError: Error {
	case forbidden(String)
	case invalidClient
	case failed(String)
}

class ConversationsManager: NSObject, ObservableObject {
	private enum Constants {
		static let apiBaseURLString = "https://conversations.twilio.com/v1"
		static let uniqueConversationName = "general"
		static let messagesDownloadPageSize: UInt = 100
	}

	private(set) var cancellables: Set<AnyCancellable> = []
	weak var messagesDelegate: ConversationMessagesDelegate?
	@Published private(set) var client: TwilioConversationsClient?
	@Published private(set) var conversations: Set<TCHConversation> = []
	@Published private(set) var messages: [String: [TCHMessage]] = [:]
	private var conversationTokens: CHConversations?

	func refreshAccessToken(completion: @escaping AllieResultCompletion<Bool>) {
		APIClient.shared.getConservations()
			.sink { result in
				if case .failure(let error) = result {
					ALog.error("Error retrieving token \(error.localizedDescription)")
					completion(.failure(error))
				}
			} receiveValue: { [weak self] conversations in
				self?.conversationTokens = conversations
				if self?.client != nil {
					self?.updateToken(token: conversations.tokens.first, completion: completion)
				} else {
					self?.login(token: conversations.tokens.first, completion: completion)
				}
			}.store(in: &cancellables)
	}

	func updateToken(token: CHConversations.Token?, completion: @escaping AllieResultCompletion<Bool>) {
		guard let token = token else {
			completion(.failure(AllieError.missing("Unable to update token, missing token")))
			return
		}
		client?.updateToken(token.accessToken, completion: { result in
			if result.isSuccessful {
				ALog.info("Access token refreshed")
				completion(.success(true))
			} else if let error = result.error {
				completion(.failure(error))
			} else {
				completion(.failure(URLError(.badServerResponse)))
			}
		})
	}

	func send(message: String, for conversation: TCHConversation, completion: @escaping AllieResultCompletion<TCHMessage>) {
		let messageOptions = TCHMessageOptions().withBody(message)
		conversation.sendMessage(with: messageOptions, completion: { result, message in
			if let message = message, result.isSuccessful {
				completion(.success(message))
			} else if let error = result.error {
				completion(.failure(error))
			} else {
				completion(.failure(ConversationsManagerError.failed("To Send Message")))
			}
		})
	}

	func loginFromServer(identity: String, completion: @escaping AllieBoolCompletion) {
		APIClient.shared.getConservations()
			.sink { result in
				if case .failure(let error) = result {
					ALog.error("Error retrieving token \(error.localizedDescription)")
					completion(false)
				}
			} receiveValue: { [weak self] conversations in
				guard let accessToken = conversations.tokens.first?.accessToken else {
					completion(false)
					return
				}
				TwilioConversationsClient.conversationsClient(withToken: accessToken, properties: nil, delegate: self) { result, client in
					self?.client = client
					completion(result.isSuccessful)
				}
			}.store(in: &cancellables)
	}

	func login(token: CHConversations.Token?, completion: @escaping AllieResultCompletion<Bool>) {
		guard let accessToken = token?.accessToken else {
			completion(.failure(AllieError.missing("Unable to login, missing token")))
			return
		}
		TwilioConversationsClient.conversationsClient(withToken: accessToken, properties: nil, delegate: self) { [weak self] result, client in
			self?.client = client
			ALog.info("Login Result \(result)")
			completion(.success(true))
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

	func createConversation(uniqueName: String, friendlyName: String?) -> AnyPublisher<TCHConversation, Error> {
		guard let client = self.client else {
			return Fail(error: ConversationsManagerError.invalidClient).eraseToAnyPublisher()
		}
		var options: [String: Any] = [TCHConversationOptionUniqueName: uniqueName]
		if let name = friendlyName {
			options[TCHConversationOptionFriendlyName] = name
		}
		return Future { promise in
			client.createConversation(options: options) { result, conversation in
				if let conversation = conversation, result.isSuccessful { // success
					promise(.success(conversation))
				} else if let error = result.error {
					promise(.failure(error))
				} else {
					promise(.failure(ConversationsManagerError.forbidden("Unable to create conversation, unkown error")))
				}
			}
		}.eraseToAnyPublisher()
	}

	func checkConversationCreation(completion: @escaping (TCHResult?, TCHConversation?) -> Void) {
		guard let client = client else {
			return
		}
		client.conversation(withSidOrUniqueName: Constants.uniqueConversationName) { result, conversation in
			completion(result, conversation)
		}
		// let myConversations = client.myConversations()
		// completion(TCHResult(), client.myConversations()?.first)
	}

	func join(conversation: TCHConversation, completion: @escaping AllieResultCompletion<Bool>) {
		conversations.insert(conversation)
		if conversation.status == .joined {
			loadPreviousMessages(for: conversation, completion: completion)
		} else {
			conversation.join(completion: { [weak self] result in
				ALog.info("Result of conversation join: \(result.resultText ?? "No Result")")
				if result.isSuccessful {
					self?.loadPreviousMessages(for: conversation, completion: completion)
				} else {
					completion(.failure(ConversationsManagerError.failed("To join conversation")))
				}
			})
		}
	}

	func loadPreviousMessages(for conversation: TCHConversation, completion: @escaping AllieResultCompletion<Bool>) {
		conversation.getLastMessages(withCount: Constants.messagesDownloadPageSize) { [weak self] result, messages in
			if let messages = messages, result.isSuccessful {
				self?.messages[conversation.id] = messages
				completion(.success(true))
			} else if let error = result.error {
				completion(.failure(error))
			} else {
				completion(.failure(ConversationsManagerError.failed("To Load Previous Messages")))
			}
		}
	}
}

// - Messages Data Source
extension ConversationsManager {
	func numberOfMessages(for conversation: TCHConversation?) -> Int {
		guard let conversation = conversation else {
			return 0
		}
		return messages[conversation.id]?.count ?? 0
	}

	func message(for conversation: TCHConversation?, at indexPath: IndexPath) -> TCHMessage? {
		guard let conversation = conversation else {
			return nil
		}
		return messages[conversation.id]?[indexPath.section]
	}

	func messages(for conversation: TCHConversation?) -> [TCHMessage]? {
		guard let conversation = conversation else {
			return nil
		}
		return messages[conversation.id]
	}
}

// - TwilioClient
extension ConversationsManager: TwilioConversationsClientDelegate {
	func conversationsClient(_ client: TwilioConversationsClient, connectionStateUpdated state: TCHClientConnectionState) {
		ALog.trace("connectionStateUpdated:")
	}

	func conversationsClientTokenWillExpire(_ client: TwilioConversationsClient) {
		ALog.info("Access token will expire.")
		refreshAccessToken { result in
			switch result {
			case .success:
				ALog.info("refreshed token")
			case .failure(let error):
				ALog.error("Unable to update the token \(error.localizedDescription)")
			}
		}
	}

	func conversationsClientTokenExpired(_ client: TwilioConversationsClient) {
		ALog.info("Access token expired.")
		refreshAccessToken { result in
			switch result {
			case .success:
				ALog.info("refreshed token")
			case .failure(let error):
				ALog.error("Unable to update the token \(error.localizedDescription)")
			}
		}
	}

	func conversationsClient(_ client: TwilioConversationsClient, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
		guard status == .completed else {
			return
		}

		if let conversations = client.myConversations(), !conversations.isEmpty {
			self.conversations = Set(conversations)
		}
	}

	func conversationsClient(_ client: TwilioConversationsClient, conversationAdded conversation: TCHConversation) {
		ALog.trace("conversationAdded:")
		conversations.insert(conversation)
	}

	func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, updated: TCHConversationUpdate) {
		conversations.insert(conversation)
		ALog.trace("conversation:updated:")
	}

	func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, synchronizationStatusUpdated status: TCHConversationSynchronizationStatus) {
		ALog.trace("conversation:synchronizationStatusUpdated:")
	}

	func conversationsClient(_ client: TwilioConversationsClient, conversationDeleted conversation: TCHConversation) {
		ALog.trace("conversation:conversationDeleted:")
		conversations.remove(conversation)
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
		var conversationMessages = messages[conversation.id] ?? []
		conversationMessages.append(message)
		messages[conversation.id] = conversationMessages
		// Changes to the delegate should occur on the UI thread
		DispatchQueue.main.async { [weak self] in
			guard let strongSelf = self else {
				return
			}
			strongSelf.messagesDelegate?.conversationsManager(strongSelf, reloadMessagesFor: conversation)
			strongSelf.messagesDelegate?.conversationsManager(strongSelf, didReceive: message, for: conversation)
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
