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

class ConversationViewController: MessagesViewController {
	weak var conversation: TCHConversation?
	weak var conversationsManager: ConversationsManager?
	private var cancellables: Set<AnyCancellable> = []

	var patient: CHPatient? {
		CareManager.shared.patient
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
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = NSLocalizedString("CHAT", comment: "Chat")
		configureMessageCollectionView()
		configureMessageInputBar()
		if let conversation = self.conversation {
			hud.show(in: tabBarController?.view ?? view)
			conversationsManager?.join(conversation: conversation, completion: { [weak self] result in
				DispatchQueue.main.async {
					self?.hud.dismiss(animated: false)
					switch result {
					case .failure(let error):
						ALog.error("\(error)")
					case .success:
						self?.messagesCollectionView.reloadData()
					}
				}
			})
		}
		conversationsManager?.messagesDelegate = self

		conversationsManager?.$codexUsers
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
	}

	func configureMessageCollectionView() {
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
		messageInputBar.sendButton.setTitleColor(
			UIColor.allieGray.withAlphaComponent(0.3),
			for: .highlighted
		)
	}

	func isLastSectionVisible(messageList: [TCHMessage]) -> Bool {
		guard !messageList.isEmpty else {
			return false
		}
		let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)

		return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
	}
}

extension ConversationViewController: ConversationMessagesDelegate {
	func conversationsManager(_ manager: ConversationsManager, reloadMessagesFor conversation: TCHConversation) {
		messagesCollectionView.reloadData()
	}

	func conversationsManager(_ manager: ConversationsManager, didReceive message: TCHMessage, for conversation: TCHConversation) {
		ALog.trace("Did Recieve message")
	}
}

extension ConversationViewController: MessagesDataSource {
	func currentSender() -> SenderType {
		CareManager.shared.patient ?? CHParticipant(name: "Patient")
	}

	func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
		conversationsManager?.message(for: conversation, at: indexPath) ?? TCHMessage()
	}

	func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
		conversationsManager?.numberOfMessages(for: conversation) ?? 0
	}

	func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
		if indexPath.section % 3 == 0 {
			return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.allieGray])
		}
		return nil
	}

	func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
		NSAttributedString(string: "Read", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.allieGray])
	}

	func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
		let theMessage = message as? TCHMessage
		let name = conversationsManager?.participantFriendlyName(identifier: theMessage?.author) ?? message.sender.displayName
		return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1), .foregroundColor: UIColor.allieGray])
	}

	func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
		let dateString = formatter.string(from: message.sentDate)
		return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2), .foregroundColor: UIColor.allieGray])
	}
}

extension ConversationViewController: MessagesLayoutDelegate {}

extension ConversationViewController: MessagesDisplayDelegate {
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
		20.0
	}
}

extension ConversationViewController: MessageCellDelegate {
	func didTapAvatar(in cell: MessageCollectionViewCell) {
		ALog.trace("Avatar tapped")
	}

	func didTapMessage(in cell: MessageCollectionViewCell) {
		ALog.trace("Message tapped")
	}

	func didTapImage(in cell: MessageCollectionViewCell) {
		ALog.trace("Image tapped")
	}

	func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
		ALog.trace("Top cell label tapped")
	}

	func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
		ALog.trace("Bottom cell label tapped")
	}

	func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
		ALog.trace("Top message label tapped")
	}

	func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
		ALog.trace("Bottom label tapped")
	}

	func didTapPlayButton(in cell: AudioMessageCell) {
		ALog.trace("Audio message play tapped")
	}

	func didStartAudio(in cell: AudioMessageCell) {
		ALog.trace("Did start playing audio sound")
	}

	func didPauseAudio(in cell: AudioMessageCell) {
		ALog.trace("Did pause audio sound")
	}

	func didStopAudio(in cell: AudioMessageCell) {
		ALog.trace("Did stop audio sound")
	}

	func didTapAccessoryView(in cell: MessageCollectionViewCell) {
		ALog.trace("Accessory view tapped")
	}
}

extension ConversationViewController: MessageLabelDelegate {
	func didSelectAddress(_ addressComponents: [String: String]) {
		ALog.trace("Address Selected: \(addressComponents)")
	}

	func didSelectDate(_ date: Date) {
		ALog.trace("Date Selected: \(date)")
	}

	func didSelectPhoneNumber(_ phoneNumber: String) {
		ALog.trace("Phone Number Selected: \(phoneNumber)")
	}

	func didSelectURL(_ url: URL) {
		ALog.trace("URL Selected: \(url)")
	}

	func didSelectTransitInformation(_ transitInformation: [String: String]) {
		ALog.trace("TransitInformation Selected: \(transitInformation)")
	}

	func didSelectHashtag(_ hashtag: String) {
		ALog.trace("Hashtag selected: \(hashtag)")
	}

	func didSelectMention(_ mention: String) {
		ALog.trace("Mention selected: \(mention)")
	}

	func didSelectCustom(_ pattern: String, match: String?) {
		ALog.trace("Custom data detector patter selected: \(pattern)")
	}
}

extension ConversationViewController: InputBarAccessoryViewDelegate {
	@objc func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
		processInputBar(inputBar, text: text)
	}

	func processInputBar(_ inputBar: InputBarAccessoryView, text: String) {
		// Here we can parse for which substrings were autocompleted
		guard let conversation = self.conversation else {
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

		conversationsManager?.send(message: text, for: conversation, completion: { result in
			DispatchQueue.main.async {
				inputBar.sendButton.stopAnimating()
				switch result {
				case .failure(let error):
					ALog.error("Error sending message", error: error)
					inputBar.inputTextView.text = text
				case .success(let message):
					inputBar.inputTextView.placeholder = NSLocalizedString("YOUR_MESSAGE", comment: "Your message")
					ALog.info("Message Sent, \(message.id)")
				}
			}
		})
	}
}
