//
//  ConversationsManager.swift
//  Allie
//
//  Created by Waqar Malik on 6/17/21.
//

import Combine
import MessageKit
import OrderedCollections
import TwilioConversationsClient
import UIKit

protocol ConversationMessagesDelegate: AnyObject {
	func conversationsManager(_ manager: ConversationsManager, reloadMessagesFor conversation: TCHConversation)
	func conversationsManager(_ manager: ConversationsManager, didReceive message: TCHMessage, for conversation: TCHConversation)
	func conversationsManager(_ manager: ConversationsManager, didStartPreviousMessagesDownload conversations: [TCHConversation])
	func conversationsManager(_ manager: ConversationsManager, didFinishPreviousMessagesDownload conversations: [TCHConversation])
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
	@Injected(\.networkAPI) var networkAPI: AllieAPI

	weak var messagesDelegate: ConversationMessagesDelegate?
	@Published private(set) var client: TwilioConversationsClient? {
		didSet {
			client?.delegate = self
		}
	}

	@Published private(set) var conversations: Set<TCHConversation> = [] {
		didSet {
			ALog.info("did set conversations")
		}
	}

	@Published private(set) var messages: [String: OrderedSet<TCHMessage>] = [:] {
		didSet {
			getCodexUsers()
		}
	}

	@Published private(set) var codexUsers: [String: CHConversationsUser] = [:]
	private var conversationTokens: CHConversationsTokens?
	private var foregroundNotification: AnyCancellable?

	func configureNotifications() {
		foregroundNotification?.cancel()
		foregroundNotification = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
			.sink { [weak self] _ in
				self?.refreshAccessToken(completion: nil)
			}
	}

	func refreshAccessToken(completion: AllieResultCompletion<Bool>?) {
		networkAPI.getConservationsTokens()
			.sink { result in
				if case .failure(let error) = result {
					ALog.error("Error retrieving token \(error.localizedDescription)")
					completion?(.failure(error))
				}
			} receiveValue: { [weak self] conversationTokens in
				self?.conversationTokens = conversationTokens
				if self?.client != nil {
					self?.updateToken(token: conversationTokens.tokens.first, completion: completion)
				} else {
					self?.login(token: conversationTokens.tokens.first, completion: completion)
				}
			}.store(in: &cancellables)
	}

	func updateToken(token: CHConversationsTokens.Token?, completion: AllieResultCompletion<Bool>?) {
		guard let token = token else {
			completion?(.failure(AllieError.missing("Unable to update token, missing token")))
			return
		}
		client?.updateToken(token.accessToken, completion: { result in
			if result.isSuccessful {
				ALog.info("Access token refreshed")
				completion?(.success(true))
			} else if let error = result.error {
				completion?(.failure(error))
			} else {
				completion?(.failure(URLError(.badServerResponse)))
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
		networkAPI.getConservationsTokens()
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

	func participantFriendlyName(identifier: String?) -> String? {
		guard let id = identifier else {
			return nil
		}
		return codexUsers[id]?.name
	}

	func getCodexUsers() {
		var identifiers: Set<String> = []
		for (_, value) in messages {
			let ids: [String] = value.compactMap { message in
				let author: String = message.author ?? ""
				return self.codexUsers[author] == nil ? author : nil
			}
			if !ids.isEmpty {
				identifiers = identifiers.union(Set(ids))
			}
		}
		guard let conversationToken = conversationTokens?.tokens.first, !identifiers.isEmpty else {
			return
		}

		networkAPI.postConservationsUsers(organizationId: conversationToken.id, users: Array(identifiers))
			.sink { completionResult in
				if case .failure(let error) = completionResult {
					ALog.error("unable to get users \(error.localizedDescription)")
				}
			} receiveValue: { [weak self] users in
				let usersByKey = users.usersByKey
				self?.codexUsers.merge(usersByKey) { _, newValue in
					newValue
				}
			}.store(in: &cancellables)
	}

	func login(token: CHConversationsTokens.Token?, completion: AllieResultCompletion<Bool>?) {
		guard let accessToken = token?.accessToken else {
			completion?(.failure(AllieError.missing("Unable to login, missing token")))
			return
		}
		TwilioConversationsClient.conversationsClient(withToken: accessToken, properties: nil, delegate: self) { [weak self] result, client in
			self?.client = client
			ALog.info("Login Result \(result)")
			completion?(.success(true))
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
	}

	func join(conversation: TCHConversation, completion: @escaping AllieResultCompletion<Bool>) {
		if conversation.status == .joined {
			completion(.success(true))
		} else {
			conversation.join(completion: { result in
				ALog.info("Result of conversation join: \(result.resultText ?? "No Result")")
				if result.isSuccessful {
					completion(.success(true))
				} else if let error = result.error {
					completion(.failure(error))
				} else {
					completion(.failure(ConversationsManagerError.failed("To join conversation")))
				}
			})
		}
	}

	func getPreviousMessages(for conversations: [TCHConversation], completion: @escaping AllieResultCompletion<Bool>) {
		DispatchQueue.global(qos: .userInitiated).async { [weak self] in
			let group = DispatchGroup()
			for conversation in conversations {
				if let lastMessageIndex = conversation.lastMessageIndex {
					let index = lastMessageIndex.uintValue
					guard index > 0 else {
						continue
					}
					group.enter()
					self?.getPreviousMessages(for: conversation, index: index) { result in
						switch result {
						case .success(let success):
							ALog.info("got previous message \(success)")
						case .failure(let error):
							ALog.error("error getting previous messages \(error.localizedDescription)")
						}
						group.leave()
					}
				}
			}

			group.notify(queue: .main) {
				completion(.success(true))
			}
		}
	}

	func getPreviousMessages(for conversation: TCHConversation, index: UInt, completion: @escaping AllieResultCompletion<Bool>) {
		conversation.getMessagesBefore(index, withCount: Constants.messagesDownloadPageSize) { [weak self] result, newMessages in
			if let newMessages = newMessages, !newMessages.isEmpty, result.isSuccessful {
				DispatchQueue.main.async {
					let currentMessages = self?.messages[conversation.id] ?? []
					var newSet = OrderedSet(newMessages)
					newSet.append(contentsOf: currentMessages)
					self?.messages[conversation.id] = newSet
				}
				if newMessages.count == Constants.messagesDownloadPageSize {
					let newIndex = max(0, index - Constants.messagesDownloadPageSize)
					if newIndex > 0 {
						self?.getPreviousMessages(for: conversation, index: newIndex, completion: completion)
					} else {
						completion(.success(true))
					}
				} else {
					completion(.success(true))
				}
			} else if let error = result.error {
				ALog.error("Error Feteching older messages \(error.debugDescription)")
				completion(.failure(error))
			} else {
				completion(.success(true))
			}
		}
	}

	func getLastMessages(for conversation: TCHConversation, completion: @escaping AllieResultCompletion<Bool>) {
		conversation.getLastMessages(withCount: Constants.messagesDownloadPageSize, completion: { [weak self] result, newMessages in
			if let newMessages = newMessages, !newMessages.isEmpty, result.isSuccessful {
				DispatchQueue.main.async {
					let currentMessages = self?.messages[conversation.id] ?? []
					var newSet = OrderedSet(newMessages)
					newSet.append(contentsOf: currentMessages)
					self?.messages[conversation.id] = newSet
				}
				completion(.success(true))
			} else if let error = result.error {
				ALog.error("Error Feteching older messages \(error.debugDescription)")
				completion(.failure(error))
			}
		})
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
		let message = messages[conversation.id]?[indexPath.section]
		return message
	}

	func messages(for conversation: TCHConversation?) -> OrderedSet<TCHMessage>? {
		guard let conversation = conversation else {
			return nil
		}
		return messages[conversation.id]
	}
}

// - TwilioClient
extension ConversationsManager: TwilioConversationsClientDelegate {
	func conversationsClient(_ client: TwilioConversationsClient, connectionStateUpdated state: TCHClientConnectionState) {
		ALog.info("connectionStateUpdated: \(state.rawValue)")
		if state == .denied {
			refreshAccessToken(completion: nil)
		}
	}

	func conversationsClientTokenWillExpire(_ client: TwilioConversationsClient) {
		ALog.info("Access token will expire.")
		refreshAccessToken(completion: nil)
	}

	func conversationsClientTokenExpired(_ client: TwilioConversationsClient) {
		ALog.info("Access token expired.")
		refreshAccessToken(completion: nil)
	}

	func conversationsClient(_ client: TwilioConversationsClient, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
		guard status == .completed else {
			return
		}

		if let conversations = client.myConversations(), !conversations.isEmpty {
			self.conversations = Set(conversations)
			messagesDelegate?.conversationsManager(self, didStartPreviousMessagesDownload: conversations)
			getPreviousMessages(for: conversations) { [weak self] result in
				if case .failure(let error) = result {
					ALog.error("error = \(error.localizedDescription)")
				}
				if let strongSelf = self {
					strongSelf.messagesDelegate?.conversationsManager(strongSelf, didFinishPreviousMessagesDownload: conversations)
				}
			}
		}
	}

	func conversationsClient(_ client: TwilioConversationsClient, conversationAdded conversation: TCHConversation) {
		ALog.info("conversationAdded:")
		conversations.insert(conversation)
		messagesDelegate?.conversationsManager(self, didStartPreviousMessagesDownload: [conversation])
		getPreviousMessages(for: [conversation]) { [weak self] result in
			if case .failure(let error) = result {
				ALog.error("error = \(error.localizedDescription)")
			}
			if let strongSelf = self {
				strongSelf.messagesDelegate?.conversationsManager(strongSelf, didFinishPreviousMessagesDownload: [conversation])
			}
		}
	}

	func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, updated: TCHConversationUpdate) {
		conversations.insert(conversation)
		ALog.info("conversation:updated:")
	}

	func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, synchronizationStatusUpdated status: TCHConversationSynchronizationStatus) {
		ALog.info("conversation:synchronizationStatusUpdated:")
	}

	func conversationsClient(_ client: TwilioConversationsClient, conversationDeleted conversation: TCHConversation) {
		ALog.info("conversation:conversationDeleted:")
		conversations.remove(conversation)
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

	func conversationsClient(_ client: TwilioConversationsClient, notificationUpdatedBadgeCount badgeCount: UInt) {
		ALog.info("notificationUpdatedBadgeCount: \(badgeCount)")
	}
}
