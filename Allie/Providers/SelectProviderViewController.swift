//
//  SelectProviderViewController.swift
//  Allie
//
//  Created by Waqar Malik on 6/24/21.
//

import Combine
import JGProgressHUD
import SDWebImage
import SwiftUI
import UIKit

class SelectProviderViewController: UICollectionViewController {
	class var layout: UICollectionViewLayout {
		var listConfiguaration = UICollectionLayoutListConfiguration(appearance: .plain)
		listConfiguaration.headerMode = .supplementary
		listConfiguaration.footerMode = .none
		let layout = UICollectionViewCompositionalLayout.list(using: listConfiguaration)
		return layout
	}

	private let hud: JGProgressHUD = {
		let view = JGProgressHUD(style: .dark)
		view.vibrancyEnabled = true
		view.textLabel.text = NSLocalizedString("LOADING", comment: "Loading")
		return view
	}()

	var doneAction: AllieBoolCompletion?
	var showDetailAction: ((CHOrganization) -> Void)?

	private var cancellables: Set<AnyCancellable> = []
	var dataSource: UICollectionViewDiffableDataSource<Int, CHOrganization>!
	var isModel = true

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.back"), style: .plain, target: nil, action: nil)
		if isModel {
			let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done(_:)))
			navigationItem.rightBarButtonItem = doneBarButtonItem
			let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
			navigationItem.leftBarButtonItem = cancelBarButtonItem
		}

		let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, CHOrganization> { [weak self] cell, _, item in
			var configuration = cell.defaultContentConfiguration()
			SDWebImageManager.shared.loadImage(with: item.imageURL, options: [.scaleDownLargeImages], progress: nil) { image, _, _, _, _, _ in
				configuration.image = image
			}
			configuration.text = item.name
			if let contains = self?.organizations.registered.contains(item), contains {
				cell.accessories = [.checkmark(options: .init(tintColor: .allieGray)), .disclosureIndicator(options: .init(tintColor: .allieGray))]
			} else {
				cell.accessories = [.disclosureIndicator(options: .init(tintColor: .allieGray))]
			}
			cell.contentConfiguration = configuration
		}

		let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { headerView, _, _ in
			var configuration = headerView.defaultContentConfiguration()
			configuration.text = NSLocalizedString("CHOOSE_PROVIDER.title", comment: "Choose your Healthcare Provider")
			configuration.textProperties.font = .boldSystemFont(ofSize: 26.0)
			configuration.textProperties.color = .allieGray
			configuration.textProperties.alignment = .center
			configuration.directionalLayoutMargins = .init(top: 50.0, leading: 20.0, bottom: 50.0, trailing: 20.0)
			headerView.backgroundColor = .allieWhite
			headerView.contentConfiguration = configuration
		}

		collectionView?.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: UICollectionViewListCell.reuseIdentifier)
		collectionView?.register(UICollectionViewListCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UICollectionViewListCell.reuseIdentifier)
		dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, identifier: CHOrganization) -> UICollectionViewCell? in
			let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
			return cell
		}

		dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath -> UICollectionReusableView? in
			if elementKind == UICollectionView.elementKindSectionHeader {
				return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
			}
			return nil
		}

		fetchOrganizations()
	}

	deinit {
		cancellables.forEach { cancellable in
			cancellable.cancel()
		}
		cancellables.removeAll()
	}

	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		defer {
			collectionView.deselectItem(at: indexPath, animated: true)
		}
		guard let item = dataSource.itemIdentifier(for: indexPath) else {
			return
		}
		detailViewModel = ProviderDetailViewModel(organization: item)
		if let viewModel = detailViewModel {
			viewModel.isRegistered = organizations.registered.contains(item)
			if !organizations.registered.contains(item), !organizations.registered.isEmpty {
				viewModel.shouldShowAlert = true
			}
			viewModel.$isRegistered
				.dropFirst()
				.sink { [weak self] _ in
					guard let strongSelf = self else {
						return
					}
					strongSelf.navigationController?.popViewController(animated: true) { [weak self] in
						self?.detailViewModel = nil
						self?.fetchOrganizations(animated: true)
					}
				}.store(in: &cancellables)
			let detailView = ProviderDetailView(viewModel: viewModel)
			let hostingController = UIHostingController(rootView: detailView)
			navigationController?.show(hostingController, sender: self)
		}
	}

	private var detailViewModel: ProviderDetailViewModel?
	var organizations = CHOrganizations(available: [], registered: [])
	func process(organizations: CHOrganizations) {
		self.organizations = organizations
		var snapshot = NSDiffableDataSourceSnapshot<Int, CHOrganization>()
		snapshot.appendSections([0])
		snapshot.appendItems(organizations.available, toSection: 0)
		dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
			ALog.info("Did finish applying snapshot")
			self?.collectionView.reloadData()
		}
	}

	func fetchOrganizations(animated: Bool = true) {
		if animated {
			hud.show(in: navigationController?.view ?? view)
		}
		APIClient.shared.getOrganizations()
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				if case .failure(let error) = completion {
					ALog.error("Unable to download organizations", error: error)
				}
				if animated {
					self?.hud.dismiss()
				}
			} receiveValue: { [weak self] response in
				self?.process(organizations: response)
			}.store(in: &cancellables)
	}

	@objc func cancel(_ sender: Any?) {
		doneAction?(true)
	}

	@objc func done(_ sender: Any?) {
		doneAction?(false)
	}
}
