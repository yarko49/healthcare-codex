//
//  ChatViewController.swift
//  Allie
//
//  Created by Waqar Malik on 4/14/21.
//

import Combine
import InputBarAccessoryView
import JGProgressHUD
import MessageKit
import TwilioConversationsClient
import UIKit

class ChatViewController: MessagesViewController {
	var conversation: TCHConversation? {
		conversationManager.conversation
	}

	let conversationManager: ConversationsManager = {
		let manager = ConversationsManager()
		return manager
	}()

	private var cancellables: Set<AnyCancellable> = []
	@Injected(\.careManager) var careManager: CareManager

	var patient: CHPatient? {
		careManager.patient
	}

	private let hud: JGProgressHUD = {
		let view = JGProgressHUD(style: .dark)
		view.vibrancyEnabled = true
		view.textLabel.text = NSLocalizedString("LOADING", comment: "Loading")
		return view
	}()

	private let formatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		return formatter
	}()

	deinit {
		cancellables.forEach { cancellable in
			cancellable.cancel()
		}
		conversationManager.messagesDelegate = nil
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = NSLocalizedString("CHAT", comment: "Chat")
		configureMessageCollectionView()
		configureMessageInputBar()
		subscribeToConversation()

		conversationManager.messagesDelegate = self
		conversationManager.$codexUsers
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { _ in
				self.messagesCollectionView.reloadData()
			}).store(in: &cancellables)

		if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
			layout.setMessageIncomingAvatarSize(.zero)
			layout.setMessageOutgoingAvatarSize(.zero)
			layout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 8)))
			layout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 8, bottom: 5, right: 0)))
		}
		configureTokens()
	}

	func configureTokens() {
		hud.show(in: tabBarController?.view ?? view)
		conversationManager.refreshAccessToken { [weak self] result in
			DispatchQueue.main.async {
				self?.hud.dismiss(animated: false)
				switch result {
				case .failure(let error):
					self?.showError(message: error.localizedDescription)
				case .success:
					self?.messagesCollectionView.reloadData()
				}
			}
		}
		conversationManager.configureNotifications()
	}

	func subscribeToConversation() {
		conversationManager.$conversation
			.receive(on: RunLoop.main, options: nil)
			.sink { [weak self] updated in
				guard let conversation = updated else {
					return
				}
				self?.conversationManager.join(conversation: conversation, completion: { result in
					self?.hud.dismiss(animated: false)
					switch result {
					case .failure(let error):
						ALog.error("\(error)")
					case .success:
						self?.messagesCollectionView.reloadData()
					}
				})
			}.store(in: &cancellables)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		UIApplication.shared.applicationIconBadgeNumber = 0
		UserDefaults.standard.chatNotificationsCount = 0
		AppDelegate.mainCoordinator?.updateBadges(count: 0)
		messagesCollectionView.scrollToLastItem()
	}

	func configureMessageCollectionView() {
		additionalBottomInset = 16.0
		messagesCollectionView.messagesDataSource = self
		messagesCollectionView.messagesLayoutDelegate = self
		messagesCollectionView.messagesDisplayDelegate = self
		messagesCollectionView.messageCellDelegate = self

		scrollsToLastItemOnKeyboardBeginsEditing = true
		maintainPositionOnKeyboardFrameChanged = true
		showMessageTimestampOnSwipeLeft = true // default false
	}

	func configureMessageInputBar() {
		messageInputBar.delegate = self
		messageInputBar.inputTextView.tintColor = .allieGray
		messageInputBar.sendButton.setTitleColor(.allieGray, for: .normal)
		messageInputBar.sendButton.setTitleColor(UIColor.allieGray.withAlphaComponent(0.3), for: .highlighted)
	}

	func isLastSectionVisible(messageList: [TCHMessage]) -> Bool {
		guard !messageList.isEmpty else {
			return false
		}
		let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)

		return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
	}

	func showError(message: String?) {
		let controller = UIAlertController(title: NSLocalizedString("ERROR", comment: "Error"), message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) { _ in
		}
		controller.addAction(okAction)
		navigationController?.showDetailViewController(controller, sender: self)
	}
}

extension ChatViewController: ConversationMessagesDelegate {
	func conversationsManager(_ manager: ConversationsManager, didStartPreviousMessagesDownload conversations: [TCHConversation]) {
		DispatchQueue.main.async {
			self.hud.show(in: self.tabBarController?.view ?? self.navigationController?.view ?? self.view)
		}
	}

	func conversationsManager(_ manager: ConversationsManager, didFinishPreviousMessagesDownload conversations: [TCHConversation]) {
		DispatchQueue.main.async {
			self.hud.dismiss()
		}
	}

	func conversationsManager(_ manager: ConversationsManager, reloadMessagesFor conversation: TCHConversation) {
		messagesCollectionView.reloadData()
	}

	func conversationsManager(_ manager: ConversationsManager, didReceive message: TCHMessage, for conversation: TCHConversation) {
		ALog.trace("Did Recieve message")
		messagesCollectionView.scrollToLastItem()
	}
}

extension ChatViewController: MessagesDataSource {
	func currentSender() -> SenderType {
		careManager.patient ?? CHParticipant(name: "Patient")
	}

	func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
		conversationManager.message(for: conversation, at: indexPath) ?? TCHMessage()
	}

	func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
		conversationManager.numberOfMessages(for: conversation)
	}

	func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
		if indexPath.section % 3 == 0 {
			return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.allieGray])
		}
		return nil
	}

	func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
		NSAttributedString(string: NSLocalizedString("READ", comment: "Read"), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.allieGray])
	}

	func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
		let theMessage = message as? TCHMessage
		var name = conversationManager.participantFriendlyName(identifier: theMessage?.author) ?? message.sender.displayName
		if message.sender.senderId != patient?.id {
			if let jobTitle = conversationManager.jobTitle(identifier: theMessage?.author) {
				name += "\n" + jobTitle
			}
		}
		return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1), .foregroundColor: UIColor.allieGray])
	}

	func messageTimestampLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
		let dateString = formatter.string(from: message.sentDate)
		return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2), .foregroundColor: UIColor.allieGray])
	}
}

extension ChatViewController: MessagesLayoutDelegate {}

extension ChatViewController: MessagesDisplayDelegate {
	func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
		message.sender.senderId == patient?.id ? .allieChatDark : .allieChatLight
	}

	func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
		message.sender.senderId == patient?.id ? .allieWhite : .allieGray
	}

	func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
		20.0
	}

	func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
		message.sender.senderId == patient?.id ? 20.0 : 40
	}
}

extension ChatViewController: MessageCellDelegate {}

extension ChatViewController: MessageLabelDelegate {}

extension ChatViewController: InputBarAccessoryViewDelegate {
	@objc func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
		processInputBar(inputBar, message: text)
	}

	func processInputBar(_ inputBar: InputBarAccessoryView, message: String) {
		// Here we can parse for which substrings were autocompleted
		guard let conversation = conversation else {
			return
		}

		let attributedText = inputBar.inputTextView.attributedText!
		let range = NSRange(location: 0, length: attributedText.length)
		attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { _, range, _ in
			let substring = attributedText.attributedSubstring(from: range)
			let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
			ALog.trace("Autocompleted: `\(substring),` with context: \(context ?? [])")
		}

		// let components = inputBar.inputTextView.components
		inputBar.inputTextView.text = ""
		inputBar.invalidatePlugins()
		// Send button activity animation
		inputBar.sendButton.startAnimating()
		inputBar.inputTextView.placeholder = NSLocalizedString("SENDING", comment: "Sending...")
		// Resign first responder for iPad split view
		inputBar.inputTextView.resignFirstResponder()
		let updatedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
		conversationManager.send(message: updatedMessage, for: conversation, completion: { [weak self] result in
			DispatchQueue.main.async {
				inputBar.sendButton.stopAnimating()
				switch result {
				case .failure(let error):
					ALog.error("Error sending message", error: error)
					inputBar.inputTextView.text = updatedMessage
				case .success(let message):
					inputBar.inputTextView.placeholder = NSLocalizedString("YOUR_MESSAGE", comment: "Your message")
					ALog.info("Message Sent, \(message.id)")
				}
				self?.messagesCollectionView.scrollToLastItem()
			}
		})
	}
}
