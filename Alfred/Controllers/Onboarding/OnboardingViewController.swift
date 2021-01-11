//
//  OnboardingViewController.swift
//  Alfred

import AuthenticationServices
import CryptoKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import LocalAuthentication
import UIKit

class OnboardingViewController: BaseViewController, UIViewControllerTransitioningDelegate {
	var signInWithAppleAction: (() -> Void)?
	var signInWithEmailAction: (() -> Void)?
	var signupAction: (() -> Void)?

	// MARK: - Initializer

	@IBOutlet var signUpBottomButton: BottomButton!
	@IBOutlet var contentView: UIView!
	@IBOutlet var alreadyHaveAccountLabel: UILabel!
	@IBOutlet var signInButton: UIButton!
	@IBOutlet var pageControl: UIPageControl!

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
		cell.imageView.image = item.image
		cell.titleLabel.text = item.title
		cell.subtitleLabel.text = item.subtitle
	}

	override func setupView() {
		super.setupView()
		view.backgroundColor = .onboardingBackground
		navigationController?.navigationBar.isHidden = true
		pageControl.currentPage = 0

		GIDSignIn.sharedInstance()?.presentingViewController = self
		contentView.isUserInteractionEnabled = true
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(collectionView)
		NSLayoutConstraint.activate([collectionView.heightAnchor.constraint(equalToConstant: 450.0),
		                             collectionView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 0.0),
		                             view.trailingAnchor.constraint(equalToSystemSpacingAfter: collectionView.trailingAnchor, multiplier: 0.0),
		                             pageControl.topAnchor.constraint(equalToSystemSpacingBelow: collectionView.bottomAnchor, multiplier: 0.0)])

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

	override func localize() {
		super.localize()

		alreadyHaveAccountLabel.attributedText = Str.alreadyHaveAccount.with(style: .regular17, andColor: .lightGrey, andLetterSpacing: -0.32)
		signInButton.setAttributedTitle(Str.login.with(style: .regular16, andColor: .orange, andLetterSpacing: -0.32), for: .normal)
		signUpBottomButton.setAttributedTitle(Str.signup.uppercased().with(style: .semibold17, andColor: .white), for: .normal)
		signUpBottomButton.refreshCorners(value: 5)
		signUpBottomButton.setupButton()
	}

	func setupModalView() {}

	private struct IllustartionItem: Hashable {
		var image: UIImage?
		var title: String
		var subtitle: String

		static var defaultItems: [IllustartionItem] {
			[IllustartionItem(image: UIImage(named: "illustration1"), title: Str.slide1Title, subtitle: Str.slide1Desc),
			 IllustartionItem(image: UIImage(named: "illustration2"), title: Str.slide2Title, subtitle: Str.slide2Desc),
			 IllustartionItem(image: UIImage(named: "illustration3"), title: Str.slide3Title, subtitle: Str.slide3Desc)]
		}
	}

	@IBAction func signUpBottomBtnTapped(_ sender: Any) {
		showModal(viewType: .signup)
	}

	@IBAction func signInBtnTapped(_ sender: Any) {
		showModal(viewType: .signin)
	}

	private func showModal(viewType: AuthenticationOptionsViewType) {
		let viewController = AuthenticationOptionsViewController()
		viewController.viewType = viewType
		viewController.modalPresentationStyle = .custom
		viewController.modalTransitionStyle = .crossDissolve
		viewController.delegate = self
		navigationController?.present(viewController, animated: false, completion: nil)
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
			if controller.viewType == .signup {
				signupAction?()
			} else {
				signInWithEmailAction?()
			}
		}
	}
}
