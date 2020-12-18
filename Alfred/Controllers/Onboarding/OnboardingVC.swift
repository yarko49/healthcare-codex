//
//  OnboardingVC.swift
//  alfred-ios

import AuthenticationServices
import CryptoKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import LocalAuthentication
import UIKit

class OnboardingVC: BaseViewController, UIViewControllerTransitioningDelegate {
	var signInWithAppleAction: (() -> Void)?
	var signInWithEmailAction: (() -> Void)?
	var signupAction: (() -> Void)?

	// MARK: - Initializer

	@IBOutlet var googleSignInBtn: GoogleSignInButton!
	@IBOutlet var appleSignInBtn: AAPLSignInButton!
	@IBOutlet var subView: UIView!
	@IBOutlet var signLbl: UILabel!
	@IBOutlet var signUpBottomBtn: BottomButton!
	@IBOutlet var cancelBtn: UIButton!
	@IBOutlet var contentView: UIView!
	@IBOutlet var swipe: UIView!
	@IBOutlet var shadowView: UIView!
	@IBOutlet var alreadyHaveAccountLbl: UILabel!
	@IBOutlet var signInBtn: UIButton!
	@IBOutlet var bottomConstraint: NSLayoutConstraint!
	@IBOutlet var pageControl: UIPageControl!
	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var stackView: UIStackView!
	@IBOutlet var stackViewCenterXConstraint: NSLayoutConstraint!
	@IBOutlet var emailSignInBtn: EmailSignInButton!

	override func setupView() {
		super.setupView()
		navigationController?.navigationBar.isHidden = true
		setupModalView()
		setupOnboarding()

		stackViewCenterXConstraint.isActive = false
		pageControl.currentPage = 0
		scrollView.delegate = self

		let views = [subView, shadowView]
		appleSignInBtn.addTarget(self, action: #selector(signInWithApple), for: .touchUpInside)
		cancelBtn.addTarget(self, action: #selector(hideModal), for: .touchUpInside)
		for view in views {
			if let view = view {
				let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(hideModal))
				downSwipe.direction = .down
				view.addGestureRecognizer(downSwipe)
			}
		}

		GIDSignIn.sharedInstance()?.presentingViewController = self
		contentView.isUserInteractionEnabled = true

		bottomConstraint.constant = -UIScreen.main.bounds.height
		shadowView.isHidden = true
		shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
	}

	override func localize() {
		super.localize()

		alreadyHaveAccountLbl.attributedText = Str.alreadyHaveAccount.with(style: .regular17, andColor: .lightGrey, andLetterSpacing: -0.32)
		signInBtn.setAttributedTitle(Str.login.with(style: .regular16, andColor: .orange, andLetterSpacing: -0.32), for: .normal)
		signUpBottomBtn.setAttributedTitle(Str.signup.uppercased().with(style: .semibold17, andColor: .white), for: .normal)
		signUpBottomBtn.refreshCorners(value: 5)
		signUpBottomBtn.setupButton()
	}

	func setupModalView() {
		subView.translatesAutoresizingMaskIntoConstraints = false
		subView.autoresizingMask = [.flexibleTopMargin, .flexibleHeight]
		subView.layer.cornerRadius = 16.0
		subView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		subView.clipsToBounds = true
		let cancel = UILabel()
		cancel.attributedText = Str.cancel.with(style: .regular17, andColor: UIColor.veryLightGrey ?? UIColor.lightGrey, andLetterSpacing: -0.408)
		cancelBtn.setAttributedTitle(cancel.attributedText, for: .normal)
		cancelBtn.addTarget(self, action: #selector(hideModal), for: .touchUpInside)
		swipe.backgroundColor = UIColor.swipeColor
		swipe.layer.cornerRadius = 5.0
	}

	private func setupOnboarding() {
		let titles = [Str.slide1Title, Str.slide2Title, Str.slide3Title]
		let descriptions = [Str.slide1Desc, Str.slide2Desc, Str.slide3Desc]

		for index in 0 ..< titles.count {
			let view = OnboardingView(title: titles[index], descr: descriptions[index])

			stackView.addArrangedSubview(view)
			view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
		}
	}

	@IBAction func googleSignBtnTapped(_ sender: Any) {
		GIDSignIn.sharedInstance()?.signIn()
		view.layer.opacity = 1.0
		view.backgroundColor = UIColor.red.withAlphaComponent(0.5)
	}

	@objc func hideModal() {
		UIView.animate(withDuration: 0.3,
		               delay: 0.0,
		               options: [],
		               animations: {
		               	self.subView.frame.origin.x = 0
		               	self.subView.frame.origin.y = UIScreen.main.bounds.height
		               })
		bottomConstraint.constant = -subView.frame.height
		shadowView.isHidden = true
	}

	@objc func showModal(type: Int) {
		if type == 0 {
			setupModal(string: Str.signup, email: Str.signUpWithYourEmail, apple: Str.signUpWithApple, google: Str.signUpWithGoogle)
		} else {
			setupModal(string: Str.signInModal, email: Str.signInWithYourEmail, apple: Str.signInWithApple, google: Str.signInWithGoogle)
		}

		UIView.animate(withDuration: 0.3,
		               delay: 0.0,
		               options: [],
		               animations: {
		               	self.subView.frame.origin.x = 0
		               	self.subView.frame.origin.y = self.subView.frame.height
		               })
		bottomConstraint.constant = 0
		shadowView.isHidden = false
	}

	func setupModal(string: String, email: String, apple: String, google: String) {
		var attributedText = string.with(style: .semibold17, andColor: UIColor.black, andLetterSpacing: -0.408)
		signLbl.attributedText = attributedText
		attributedText = email.with(style: .regular20, andColor: UIColor.grey, andLetterSpacing: 0.38)
		emailSignInBtn.setAttributedTitle(attributedText, for: .normal)
		googleSignInBtn.setupValues(labelTitle: google)
		appleSignInBtn.setupValues(labelTitle: apple)
	}

	@objc func signInWithApple() {
		signInWithAppleAction?()
	}

	@IBAction func signUpBottomBtnTapped(_ sender: Any) {
		showModal(type: 0)
	}

	@IBAction func signInWIthEmail(_ sender: Any) {
		if emailSignInBtn.titleLabel?.text == Str.signInWithYourEmail {
			signInWithEmailAction?()
		} else if emailSignInBtn.titleLabel?.text == Str.signUpWithYourEmail {
			signupAction?()
		}
	}

	@IBAction func signInBtnTapped(_ sender: Any) {
		showModal(type: 1)
	}

	@IBAction func signup(_ sender: Any) {}
}

extension OnboardingVC: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
		let page = Int(pageIndex)
		pageControl.currentPage = page
	}
}
