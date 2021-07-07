//
//  ConversationListViewController.swift
//  Allie
//
//  Created by Waqar Malik on 6/28/21.
//

import Combine
import JGProgressHUD
import SDWebImage
import TwilioConversationsClient
import UIKit

class ConversationListViewController: UICollectionViewController {
	class var layout: UICollectionViewLayout {
		let listConfiguaration = UICollectionLayoutListConfiguration(appearance: .plain)
		let layout = UICollectionViewCompositionalLayout.list(using: listConfiguaration)
		return layout
	}

	private let hud: JGProgressHUD = {
		let view = JGProgressHUD(style: .dark)
		view.vibrancyEnabled = true
		view.textLabel.text = NSLocalizedString("LOADING", comment: "Loading")
		return view
	}()

	private var cancellables: Set<AnyCancellable> = []
	var dataSource: UICollectionViewDiffableDataSource<Int, TCHConversation>!
	var conversationManager = ConversationsManager()
	var composeBarButtonItem: UIBarButtonItem?

	override func viewDidLoad() {
		super.viewDidLoad()
		composeBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createConversation(_:)))
		navigationItem.rightBarButtonItem = composeBarButtonItem

		collectionView!.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: UICollectionViewListCell.reuseIdentifier)
		let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, TCHConversation> { cell, _, conversation in
			var configuration = cell.defaultContentConfiguration()
			configuration.text = conversation.friendlyName ?? "Your Conversation"
			cell.accessories = [.disclosureIndicator(options: .init(tintColor: .allieGray))]
			cell.contentConfiguration = configuration
		}

		dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, identifier: TCHConversation) -> UICollectionViewCell? in
			let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
			return cell
		}

		conversationManager.$client.sink { [weak self] client in
			self?.composeBarButtonItem?.isEnabled = client != nil
		}.store(in: &cancellables)

		conversationManager.$conversations.sink { [weak self] conversations in
			self?.process(conversations: conversations)
		}.store(in: &cancellables)

		hud.show(in: tabBarController?.view ?? view)
		conversationManager.refreshAccessToken { [weak self] result in
			DispatchQueue.main.async {
				self?.hud.dismiss(animated: false)
				switch result {
				case .failure(let error):
					self?.showError(message: error.localizedDescription)
				case .success:
					self?.collectionView.reloadData()
				}
			}
		}
	}

	@objc func createConversation(_ sender: Any?) {}

	func process(conversations: Set<TCHConversation>) {
		let sorted = conversations.sorted { lhs, rhs in
			guard let lhd = lhs.dateUpdatedAsDate, let rhd = rhs.dateUpdatedAsDate else {
				return false
			}
			return lhd > rhd
		}
		var snapshot = NSDiffableDataSourceSnapshot<Int, TCHConversation>()
		snapshot.appendSections([0])
		snapshot.appendItems(sorted, toSection: 0)
		dataSource.apply(snapshot, animatingDifferences: true) {
			ALog.info("updated conversations")
		}
	}

	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		defer {
			collectionView.deselectItem(at: indexPath, animated: true)
		}

		guard let conversation = dataSource.itemIdentifier(for: indexPath) else {
			return
		}
		let viewController = ConversationViewController()
		viewController.conversation = conversation
		viewController.conversationsManager = conversationManager
		navigationController?.show(viewController, sender: self)
	}

	func showError(message: String?) {
		let controller = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .default) { _ in
		}
		controller.addAction(okAction)
		navigationController?.showDetailViewController(controller, sender: self)
	}
}
