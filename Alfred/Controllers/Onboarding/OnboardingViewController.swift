//
//  OnboardingViewController.swift
//  Alfred
//
//  Created by Waqar Malik on 1/19/21.
//

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

class OnboardingViewController: BaseViewController, UIViewControllerTransitioningDelegate {
	var signInWithAppleAction: Coordinator.ActionHandler?
	var signInWithEmailAction: Coordinator.ActionHandler?
	var signupAction: Coordinator.ActionHandler?

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .onboardingBackground

		GIDSignIn.sharedInstance()?.presentingViewController = self
		bottomStackView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(bottomStackView)
		NSLayoutConstraint.activate([bottomStackView.widthAnchor.constraint(equalToConstant: 256.0),
		                             bottomStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: bottomStackView.bottomAnchor, multiplier: 0.0),
		                             bottomStackView.heightAnchor.constraint(equalToConstant: 30.0)])

		messageLabel.translatesAutoresizingMaskIntoConstraints = false
		bottomStackView.addArrangedSubview(messageLabel)
		bottomStackView.addArrangedSubview(signInButton)
		view.addSubview(signUpButton)
		NSLayoutConstraint.activate([signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: signUpButton.bottomAnchor, multiplier: 10.0)])

		pageControl.translatesAutoresizingMaskIntoConstraints = false
		pageControl.numberOfPages = IllustartionItem.defaultItems.count
		pageControl.currentPage = 0
		view.addSubview(pageControl)
		NSLayoutConstraint.activate([pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		                             signUpButton.topAnchor.constraint(equalToSystemSpacingBelow: pageControl.bottomAnchor, multiplier: 2.5)])
		configureCollectionView()
		signInButton.addTarget(self, action: #selector(signInButtonTapped(_:)), for: .touchUpInside)
		signUpButton.addTarget(self, action: #selector(signUpBottomButtonTapped(_:)), for: .touchUpInside)
	}

	@IBAction func signUpBottomButtonTapped(_ sender: Any) {
		showModal(authorizationFlow: .signUp)
	}

	@IBAction func signInButtonTapped(_ sender: Any) {
		showModal(authorizationFlow: .signIn)
	}

	private func showModal(authorizationFlow type: AuthorizationFlowType) {
		let viewController = AuthenticationOptionsViewController()
		viewController.authorizationFlowType = type
		viewController.modalPresentationStyle = .custom
		viewController.modalTransitionStyle = .crossDissolve
		viewController.delegate = self
		navigationController?.present(viewController, animated: false, completion: nil)
	}

	private let collectionView: UICollectionView = {
		let view = UICollectionView(frame: .zero, collectionViewLayout: OnboardingViewController.collectionViewLayout)
		view.showsVerticalScrollIndicator = false
		view.showsHorizontalScrollIndicator = false
		view.isScrollEnabled = false
		view.backgroundColor = .clear
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
		return view
	}()

	private let signUpButton: UIButton = {
		let button = UIButton(type: .custom)
		button.backgroundColor = .grey
		button.layer.cornerRadius = 5.0
		button.layer.cornerCurve = .continuous
		let title = Str.signup.uppercased()
		let attributes: [NSAttributedString.Key: Any] = [.kern: 5.0, .foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 17.0, weight: .semibold)]
		let attributedText = NSAttributedString(string: title, attributes: attributes)
		button.setAttributedTitle(attributedText, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.heightAnchor.constraint(equalToConstant: 68.0).isActive = true
		button.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
		return button
	}()

	private let bottomStackView: UIStackView = {
		let stackView = UIStackView(frame: .zero)
		stackView.axis = .horizontal
		stackView.distribution = .fill
		stackView.alignment = .center
		stackView.spacing = 4.0
		return stackView
	}()

	private let messageLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.font = UIFont.preferredFont(forTextStyle: .body)
		label.textColor = .lightGrey
		label.text = Str.alreadyHaveAccount
		return label
	}()

	private let signInButton: UIButton = {
		let button = UIButton(frame: .zero)
		button.setTitle(Str.login, for: .normal)
		button.setTitleColor(.orange, for: .normal)
		button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
		button.widthAnchor.constraint(equalToConstant: 54.0).isActive = true
		return button
	}()

	fileprivate func configureCollectionView() {
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(collectionView)
		NSLayoutConstraint.activate([collectionView.heightAnchor.constraint(equalToConstant: 450.0),
		                             collectionView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: collectionView.trailingAnchor, multiplier: 0.0),
		                             signUpButton.topAnchor.constraint(equalToSystemSpacingBelow: collectionView.bottomAnchor, multiplier: 1.0)])

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
			layout.itemSize = CGSize(width: view.bounds.width, height: 450.0)
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
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.9))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
		let section = NSCollectionLayoutSection(group: group)
		section.orthogonalScrollingBehavior = .groupPagingCentered
		section.interGroupSpacing = 0.0
		let layout = UICollectionViewCompositionalLayout(section: section)
		return layout
	}
}

extension OnboardingViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		pageControl.currentPage = indexPath.item
	}
}

extension OnboardingViewController: AuthenticationOptionsViewControllerDelegate {
	func authenticationOptionsViewController(_ controller: AuthenticationOptionsViewController, didSelectProvider provider: AuthenticationProviderType) {
		switch provider {
		case .apple:
			signInWithAppleAction?()
		case .google:
			GIDSignIn.sharedInstance()?.signIn()
			view.layer.opacity = 1.0
			view.backgroundColor = UIColor.red.withAlphaComponent(0.5)
		case .email:
			if controller.authorizationFlowType == .signUp {
				signupAction?()
			} else {
				signInWithEmailAction?()
			}
		}
	}
}
