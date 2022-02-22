//
//  CarePlanViewController.swift
//  Allie
//
//  Created by Onseen on 2/20/22.
//

import Combine
import SwiftUI
import UIKit

class CarePlanViewController: BaseViewController {
	private let backgroundImage: UIImageView = {
		let backgroundImage = UIImageView()
		backgroundImage.translatesAutoresizingMaskIntoConstraints = false
		backgroundImage.image = UIImage(named: "img-care-plan")
		return backgroundImage
	}()

	private var collectionView: UICollectionView = {
		let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
		let item = NSCollectionLayoutItem(layoutSize: size)
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
		let section = NSCollectionLayoutSection(group: group)
		section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
		section.interGroupSpacing = 0
		let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100.0))
		let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
		section.boundarySupplementaryItems = [sectionHeader]
		let layout = UICollectionViewCompositionalLayout(section: section)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.bounces = false
		collectionView.backgroundColor = .clear
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.allowsSelection = false
		collectionView.register(CarePlanCell.self, forCellWithReuseIdentifier: CarePlanCell.cellID)
		collectionView.register(CarePlanFeatureCell.self, forCellWithReuseIdentifier: CarePlanFeatureCell.cellID)
		collectionView.register(CarePlanLinkCell.self, forCellWithReuseIdentifier: CarePlanLinkCell.cellID)
		collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.reuseIdentifier)
		collectionView.register(SectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionView.reuseID)
		return collectionView
	}()

	@ObservedObject var viewModel: CarePlanViewModel = .init()
	var cancellable: Set<AnyCancellable> = []

	override func viewDidLoad() {
		super.viewDidLoad()

		viewModel.loadCarePlanTask()
		setupViews()
		viewModel.$carePlans
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				self?.collectionView.reloadData()
			}
			.store(in: &cancellable)
		viewModel.$loadingState
			.receive(on: DispatchQueue.main)
			.sink { [weak self] state in
				switch state {
				case .loading:
					self?.hud.show(in: (self?.tabBarController?.view ?? self?.view)!, animated: true)
				case .failed, .success:
					self?.hud.dismiss(animated: true)
				}
			}
			.store(in: &cancellable)
	}

	deinit {
		cancellable.removeAll()
	}

	private func setupViews() {
		view.backgroundColor = .mainBackground
		[backgroundImage, collectionView].forEach { view.addSubview($0) }
		backgroundImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0).isActive = true
		backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true

		collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		collectionView.dataSource = self
	}
}

extension CarePlanViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		2
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if section == 0 {
			return viewModel.carePlans.count
		} else {
			return 2
		}
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if indexPath.section == 0 {
			let chTask = viewModel.carePlans[indexPath.row]
			let groupIdentifier = chTask.first?.groupIdentifier ?? ""
			let chGroupIdentifierType = CHGroupIdentifierType(rawValue: groupIdentifier)
			if chGroupIdentifierType == .featuredContent {
				if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarePlanFeatureCell.cellID, for: indexPath) as? CarePlanFeatureCell {
					cell.configureCell(for: chTask)
					return cell
				}
				fatalError("Can not deque CarePlanFeatureCell")
			} else if chGroupIdentifierType == .link {
				if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarePlanLinkCell.cellID, for: indexPath) as? CarePlanLinkCell {
					cell.configureCell(task: chTask)
					return cell
				}
				fatalError("Can not deque CarePlanLinkCell")
			} else {
				if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarePlanCell.cellID, for: indexPath) as? CarePlanCell {
					cell.configureCell(for: chTask)
					return cell
				}
				fatalError("Can not deque CarePlanCell")
			}
		} else {
			if indexPath.row == 0 {
				let chTask = viewModel.carePlans.first { carePlan in
					carePlan.first?.category == "education"
				}
				if let task = chTask, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarePlanFeatureCell.cellID, for: indexPath) as? CarePlanFeatureCell {
					cell.configureCell(for: task)
					return cell
				} else {
					let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.reuseIdentifier, for: indexPath)
					cell.backgroundColor = .clear
					return cell
				}
			} else {
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.reuseIdentifier, for: indexPath)
				cell.backgroundColor = .clear
				return cell
			}
		}
	}

	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionView.reuseID, for: indexPath) as? SectionView
		var headerTitle = ""
		if indexPath.section == 0 {
			headerTitle = "Your Careplan"
		} else {
			headerTitle = "Recommended"
		}
		header?.configureSection(headerTitle: headerTitle)
		return header!
	}
}
