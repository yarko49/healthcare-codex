//
//  OnboardingViewController.swift
//  Allie
//
//  Created by Waqar Malik on 1/19/21.
//

import UIKit

struct IllustartionItem: Hashable {
	var image: UIImage?
	var title: String

	static var defaultItems: [IllustartionItem] {
		[IllustartionItem(image: UIImage(named: "logo"), title: String.slide1Title),
		 IllustartionItem(image: UIImage(named: "illustration2"), title: String.slide2Title),
		 IllustartionItem(image: UIImage(named: "illustration3"), title: String.slide3Title)]
	}
}

class SignupViewController: SignupBaseViewController, UIViewControllerTransitioningDelegate {
	override func viewDidLoad() {
		controllerViewMode = .settings
		super.viewDidLoad()
		updateLabels()
		view.backgroundColor = .allieWhite
		view.addSubview(buttonStackView)
		NSLayoutConstraint.activate([buttonStackView.widthAnchor.constraint(greaterThanOrEqualToConstant: buttonWidth),
		                             buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: buttonStackView.bottomAnchor, multiplier: 2.0)])

		pageControl.numberOfPages = IllustartionItem.defaultItems.count
		pageControl.currentPage = 0
		buttonStackView.addArrangedSubview(pageControl)
		buttonStackView.addArrangedSubview(appleIdButton)
		buttonStackView.addArrangedSubview(googleSignInButton)
		buttonStackView.addArrangedSubview(emailSignInButton)
		buttonStackView.addArrangedSubview(separatorView)
		buttonStackView.addArrangedSubview(loginFlowButton)

		configureCollectionView()
		loginFlowButton.addTarget(self, action: #selector(loginFlowButtonTapped(_:)), for: .touchUpInside)
		emailSignInButton.addTarget(self, action: #selector(authenticateEmail(_:)), for: .touchUpInside)
		title = nil
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "OnboardingView"])
	}

	@IBAction func loginFlowButtonTapped(_ sender: Any) {
		let newFlow: AuthorizationFlowType = .signIn
		authorizationFlowChangedAction?(newFlow)
	}

	private let collectionView: UICollectionView = {
		let view = UICollectionView(frame: .zero, collectionViewLayout: SignupViewController.collectionViewLayout)
		view.showsVerticalScrollIndicator = false
		view.showsHorizontalScrollIndicator = false
		view.isScrollEnabled = false
		view.backgroundColor = .clear
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private var dataSource: UICollectionViewDiffableDataSource<Int, IllustartionItem>!

	private let cellRegistration = UICollectionView.CellRegistration<IllustrationCollectionViewCell, IllustartionItem> { cell, _, item in
		cell.illustrationView.imageView.image = item.image
		cell.illustrationView.titleLabel.text = item.title
	}

	let pageControl: UIPageControl = {
		let view = UIPageControl(frame: .zero)
		view.pageIndicatorTintColor = .allieLighterGray
		view.currentPageIndicatorTintColor = .allieBlack
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	override func updateLabels() {
		super.updateLabels()
		emailSignInButton.setTitle(authorizationFlowType.emailButtonTitle, for: .normal)
	}

	fileprivate func configureCollectionView() {
		let mulitplier: CGFloat = view.frame.height < 700 ? 1.0 : 10.0
		view.addSubview(collectionView)
		NSLayoutConstraint.activate([collectionView.heightAnchor.constraint(equalToConstant: IllustrationCollectionViewCell.defaultHeight),
		                             collectionView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: collectionView.trailingAnchor, multiplier: 0.0),
		                             buttonStackView.topAnchor.constraint(equalToSystemSpacingBelow: collectionView.bottomAnchor, multiplier: mulitplier)])

		collectionView.register(IllustrationCollectionViewCell.self, forCellWithReuseIdentifier: IllustrationCollectionViewCell.reuseIdentifier)
		dataSource = UICollectionViewDiffableDataSource<Int, IllustartionItem>(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
			guard let self = self else {
				return nil
			}
			let cell = collectionView.dequeueConfiguredReusableCell(using: self.cellRegistration, for: indexPath, item: item)
			return cell
		})
		collectionView.delegate = self
		if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
			layout.minimumInteritemSpacing = 0.0
			layout.minimumLineSpacing = 0.0
			layout.itemSize = CGSize(width: view.bounds.width, height: IllustrationCollectionViewCell.defaultHeight)
			layout.sectionInset = .zero
			layout.headerReferenceSize = .zero
		}

		var snapshot = dataSource.snapshot()
		snapshot.appendSections([0])
		snapshot.appendItems(IllustartionItem.defaultItems, toSection: 0)
		dataSource.apply(snapshot, animatingDifferences: false) {
			ALog.info("Did apply snapshot")
		}
	}

	class var collectionViewLayout: UICollectionViewCompositionalLayout {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
		let section = NSCollectionLayoutSection(group: group)
		section.orthogonalScrollingBehavior = .groupPagingCentered
		section.interGroupSpacing = 0.0
		let layout = UICollectionViewCompositionalLayout(section: section)
		return layout
	}

	private(set) lazy var separatorView: SeparatorView = {
		let view = SeparatorView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
		return view
	}()

	private(set) lazy var emailSignInButton: UIButton = {
		let button = UIButton.emailSignInButton
		button.layer.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
		button.layer.borderColor = UIColor.black.cgColor
		button.layer.borderWidth = 0.8
		let title = authorizationFlowType.emailButtonTitle
		button.setTitle(title, for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
		button.setTitleColor(.black, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
		button.setShadow()
		return button
	}()

	private(set) lazy var loginFlowButton: UIButton = {
		let button = UIButton(frame: .zero)
		let title = NSLocalizedString("PLEASE_LOGIN", comment: "Please, Login")
		button.setTitle(title, for: .normal)
		button.setTitleColor(.allieBlack, for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
		return button
	}()

	@IBAction private func authenticateEmail(_ sender: Any) {
		emailAuthorizationAction?(authorizationFlowType)
	}
}

extension SignupViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		pageControl.currentPage = indexPath.item
	}
}
