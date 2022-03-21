//
//  OnboardingViewController.swift
//  Allie
//
//  Created by Waqar Malik on 1/19/21.
//

import SafariServices
import SwiftUI
import UIKit

struct IllustartionItem: Hashable {
	var image: UIImage?
	var title: String

	static var defaultItems: [IllustartionItem] {
		[IllustartionItem(image: UIImage(named: "Logo"), title: String.slide1Title)]
	}
}

class SignupViewController: SignupBaseViewController, UIViewControllerTransitioningDelegate {
	override func viewDidLoad() {
		controllerViewMode = .settings
		super.viewDidLoad()
		updateLabels()
		view.backgroundColor = .mainBackground
		view.addSubview(buttonStackView)
		NSLayoutConstraint.activate([buttonStackView.widthAnchor.constraint(greaterThanOrEqualToConstant: buttonWidth),
		                             buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)])

		buttonStackView.addArrangedSubview(appleIdButton)
		buttonStackView.addArrangedSubview(googleSignInButton)
		buttonStackView.addArrangedSubview(emailSignInButton)
		textView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(textView)
		textView.delegate = self
		NSLayoutConstraint.activate([textView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 80.0),
		                             textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80.0),
		                             textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		                             textView.leadingAnchor.constraint(equalTo: buttonStackView.leadingAnchor)])

		configureCollectionView()
		emailSignInButton.addTarget(self, action: #selector(authenticateEmail(_:)), for: .touchUpInside)
		title = nil
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		navigationController?.setNavigationBarHidden(true, animated: false)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "OnboardingView"])
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
		let mutuableAttributedString = NSMutableAttributedString()
		var lines: [String] = []
		item.title.enumerateLines { line, _ in
			lines.append(line)
		}
		let firstLine = lines[0].attributedString(style: TextStyle.silkabold36, foregroundColor: UIColor.black)
		let secondLine = lines[1].capitalized.attributedString(style: TextStyle.silkabold16, foregroundColor: UIColor.allieGray, letterSpacing: 0.026)
		mutuableAttributedString.append(firstLine)
		mutuableAttributedString.append(NSAttributedString(string: "\n"))
		mutuableAttributedString.append(secondLine)
		cell.illustrationView.titleLabel.attributedText = mutuableAttributedString
	}

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

	private(set) lazy var emailSignInButton: UIButton = {
		let button = UIButton.emailSignInButton
		button.backgroundColor = .white
		button.layer.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
		button.layer.borderColor = UIColor.black.cgColor
		button.layer.borderWidth = 0.0
		let title = authorizationFlowType.emailButtonTitle
		button.setTitle(title, for: .normal)
		button.titleLabel?.font = TextStyle.silkasemibold16.font
		button.setTitleColor(.black, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(UIImage(systemName: "envelope"), for: .normal)
		button.tintColor = .black
		button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
		button.setShadow(shadowColor: .mainShadow, opacity: 0.7)
		return button
	}()

	let textView: UITextView = {
		let view = UITextView(frame: .zero)
		view.isSelectable = true
		view.isEditable = false
		view.isScrollEnabled = false
		view.textColor = .allieGray
		view.dataDetectorTypes = [.link]
		view.font = TextStyle.silkamedium14.font
		let message = NSLocalizedString("TERMS_OF_SERVICES_AND_PRIVACY_POLICY", comment: "Terms of Service & Privay Policy Message")
		let mutableAttributedString = NSMutableAttributedString(string: message, attributes: [.foregroundColor: UIColor.allieGray, .font: UIFont.systemFont(ofSize: 14.0)])
		var range = (message as NSString).range(of: NSLocalizedString("TERMS_OF_SERVICE", comment: "Terms of Service"))
		if range.location != NSNotFound {
			mutableAttributedString.addAttribute(.link, value: URL(string: AppConfig.termsOfServiceURL)!, range: range)
		}

		range = (message as NSString).range(of: NSLocalizedString("PRIVACY_POLICY", comment: "Privacy Policy"))
		if range.location != NSNotFound {
			mutableAttributedString.addAttribute(.link, value: URL(string: AppConfig.privacyPolicyURL)!, range: range)
		}
		view.attributedText = mutableAttributedString
		view.textAlignment = .center
		return view
	}()

	@IBAction private func authenticateEmail(_ sender: Any) {
		emailAuthorizationAction?(authorizationFlowType)
	}
}

extension SignupViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {}
}

extension SignupViewController: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		let viewController = SFSafariViewController(url: URL)
		navigationController?.showDetailViewController(viewController, sender: self)
		return false
	}
}

extension SignupViewController: SFSafariViewControllerDelegate {
	func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
}
