//
//  OnboardingViewController.swift
//  Allie
//
//  Created by Waqar Malik on 1/19/21.
//

import AuthenticationServices
import GoogleSignIn
import UIKit

struct IllustartionItem: Hashable {
	var image: UIImage?
	var title: String
	var subtitle: String

	static var defaultItems: [IllustartionItem] {
		[IllustartionItem(image: UIImage(named: "illustration1"), title: Str.slide1Title, subtitle: Str.slide1Desc),
		 IllustartionItem(image: UIImage(named: "illustration2"), title: Str.slide2Title, subtitle: Str.slide2Desc),
		 IllustartionItem(image: UIImage(named: "illustration3"), title: Str.slide3Title, subtitle: Str.slide3Desc)]
	}
}

class OnboardingViewController: BaseViewController, UIViewControllerTransitioningDelegate, OnboardingScreenTypable {
	var appleAuthoizationAction: Coordinable.ActionHandler?
	var emailAuthorizationAction: ((AuthorizationFlowType) -> Void)?
	var authorizationFlowChangedAction: ((AuthorizationFlowType) -> Void)?
	let screenType: OnboardingScreenType = .landing
	var authorizationFlowType: AuthorizationFlowType = .signUp {
		didSet {
			updateLabels()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		updateLabels()
		view.backgroundColor = .onboardingBackground
		GIDSignIn.sharedInstance()?.presentingViewController = self

		view.addSubview(bottomStackView)
		NSLayoutConstraint.activate([bottomStackView.widthAnchor.constraint(equalToConstant: 256.0),
		                             bottomStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: bottomStackView.bottomAnchor, multiplier: 2.0),
		                             bottomStackView.heightAnchor.constraint(equalToConstant: 30.0)])
		bottomStackView.addArrangedSubview(messageLabel)
		bottomStackView.addArrangedSubview(toggleFlowButton)

		view.addSubview(buttonStackView)
		NSLayoutConstraint.activate([buttonStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 4.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: buttonStackView.trailingAnchor, multiplier: 4.0),
		                             bottomStackView.topAnchor.constraint(equalToSystemSpacingBelow: buttonStackView.bottomAnchor, multiplier: 2.0)])

		pageControl.numberOfPages = IllustartionItem.defaultItems.count
		pageControl.currentPage = 0
		buttonStackView.spacing = view.frame.height < 700 ? 8.0 : 20.0
		buttonStackView.addArrangedSubview(pageControl)
		buttonStackView.addArrangedSubview(appleSignInButton)
		buttonStackView.addArrangedSubview(googleSignInButton)
		buttonStackView.addArrangedSubview(emailSignInButton)

		configureCollectionView()
		toggleFlowButton.addTarget(self, action: #selector(toggleFlowButtonTapped(_:)), for: .touchUpInside)
		appleSignInButton.addTarget(self, action: #selector(authenticateApple(_:)), for: .touchUpInside)
		googleSignInButton.addTarget(self, action: #selector(authenticateGoogle(_:)), for: .touchUpInside)
		emailSignInButton.addTarget(self, action: #selector(authenticateEmail(_:)), for: .touchUpInside)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "OnboardingView"])
	}

	@IBAction func toggleFlowButtonTapped(_ sender: Any) {
		let newFlow: AuthorizationFlowType = authorizationFlowType == .signIn ? .signUp : .signIn
		authorizationFlowChangedAction?(newFlow)
	}

	private let collectionView: UICollectionView = {
		let view = UICollectionView(frame: .zero, collectionViewLayout: OnboardingViewController.collectionViewLayout)
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
		cell.illustrationView.subtitleLabel.text = item.subtitle
	}

	let pageControl: UIPageControl = {
		let view = UIPageControl(frame: .zero)
		view.pageIndicatorTintColor = .lightGray
		view.currentPageIndicatorTintColor = .black
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let buttonStackView: UIStackView = {
		let stackView = UIStackView(frame: .zero)
		stackView.axis = .vertical
		stackView.distribution = .fill
		stackView.alignment = .fill
		stackView.spacing = 8.0
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()

	private let bottomStackView: UIStackView = {
		let stackView = UIStackView(frame: .zero)
		stackView.axis = .horizontal
		stackView.distribution = .fill
		stackView.alignment = .center
		stackView.spacing = 4.0
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()

	private let messageLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.font = UIFont.preferredFont(forTextStyle: .body)
		label.textColor = .lightGrey
		label.text = Str.alreadyHaveAccount
		label.adjustsFontSizeToFitWidth = true
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let toggleFlowButton: UIButton = {
		let button = UIButton(frame: .zero)
		button.setTitle(Str.login, for: .normal)
		button.setTitleColor(.orange, for: .normal)
		button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
		button.widthAnchor.constraint(equalToConstant: 56.0).isActive = true
		return button
	}()

	fileprivate func updateLabels() {
		googleSignInButton.setTitle(authorizationFlowType.googleButtonTitle, for: .normal)
		emailSignInButton.setTitle(authorizationFlowType.emailButtonTitle, for: .normal)
		messageLabel.text = authorizationFlowType.message
		toggleFlowButton.setTitle(authorizationFlowType.toggleButtonTitle, for: .normal)
	}

	fileprivate func configureCollectionView() {
		let mulitplier: CGFloat = view.frame.height < 700 ? 1.0 : 10.0
		view.addSubview(collectionView)
		NSLayoutConstraint.activate([collectionView.heightAnchor.constraint(equalToConstant: IllustrationCollectionViewCell.defaultHeight),
		                             collectionView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: collectionView.trailingAnchor, multiplier: 0.0),
		                             buttonStackView.topAnchor.constraint(equalToSystemSpacingBelow: collectionView.bottomAnchor, multiplier: mulitplier)])

		collectionView.register(IllustrationCollectionViewCell.self, forCellWithReuseIdentifier: IllustrationCollectionViewCell.reuseIdentifier)
		dataSource = UICollectionViewDiffableDataSource<Int, IllustartionItem>(collectionView: collectionView, cellProvider: { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
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

	private(set) lazy var appleSignInButton: ASAuthorizationAppleIDButton = {
		let button = ASAuthorizationAppleIDButton(type: self.authorizationFlowType.appleAuthButtonType, style: .black)
		button.cornerRadius = 5.0
		button.layer.cornerCurve = .continuous
		button.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
		return button
	}()

	@IBAction private func authenticateApple(_ sender: Any) {
		appleAuthoizationAction?()
	}

	private(set) lazy var googleSignInButton: UIButton = {
		let button = UIButton.googleSignInButton
		button.layer.cornerRadius = 5.0
		button.layer.cornerCurve = .continuous
		let title = authorizationFlowType.googleButtonTitle
		button.setTitle(title, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
		return button
	}()

	@IBAction private func authenticateGoogle(_ sender: Any) {
		GIDSignIn.sharedInstance()?.signIn()
	}

	private(set) lazy var emailSignInButton: UIButton = {
		let button = UIButton.emailSignInButton
		button.layer.cornerRadius = 5.0
		button.layer.cornerCurve = .continuous
		let title = authorizationFlowType.emailButtonTitle
		button.setTitle(title, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
		return button
	}()

	@IBAction private func authenticateEmail(_ sender: Any) {
		emailAuthorizationAction?(authorizationFlowType)
	}
}

extension OnboardingViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		pageControl.currentPage = indexPath.item
	}
}
