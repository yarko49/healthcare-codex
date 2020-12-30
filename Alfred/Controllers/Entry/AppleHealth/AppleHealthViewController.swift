import Foundation
import UIKit

enum ComingFromScreen {
	case welcome
	case welcomeSuccess
	case welcomeFailure
	case myProfile
	case myDevices
	case activate
}

class AppleHealthViewController: BaseViewController {
	var backBtnAction: (() -> Void)?
	var nextBtnAction: (() -> Void)?
	var notNowAction: (() -> Void)?
	var activateAction: (() -> Void)?
	var signInAction: (() -> Void)?

	var comingFrom: ComingFromScreen?

	@IBOutlet var stackView: UIStackView!
	@IBOutlet var nextButton: BottomButton!
	@IBOutlet var bottomView: UIView!
	@IBOutlet var rightButton: UIButton!
	@IBOutlet var leftButton: UIButton!

	override func viewWillAppear(_ animated: Bool) {
		if comingFrom == .welcome {
			signInAction?()
		}
	}

	override func setupView() {
		super.setupView()
		setupTexts()
		setupNavBar()
		nextButton.addTarget(self, action: #selector(nextBtnTapped), for: .touchUpInside)
	}

	private func setupNavBar() {
		let navBar = navigationController?.navigationBar
		if comingFrom == .myProfile || comingFrom == .welcome {
			navBar?.isHidden = false
			navigationItem.leftBarButtonItem = comingFrom == .welcome ? nil : UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backBtnTapped))
			navigationItem.leftBarButtonItem?.tintColor = UIColor.black
			navigationItem.setHidesBackButton(comingFrom == .welcome, animated: true)
			view.isUserInteractionEnabled = true
		} else {
			navBar?.isHidden = true
		}
	}

	func setupTexts() {
		switch comingFrom {
		case .welcome:
			title = Str.welcome
			reusableView(title: "", descr: "")
		case .welcomeSuccess:
			stackView.arrangedSubviews.forEach { view in
				view.isHidden = true
			}
			reusableView(title: Str.successfulSignUp, descr: Str.continueProfile, image: "successIcon")
		case .welcomeFailure:
			stackView.arrangedSubviews.forEach { view in
				view.isHidden = true
			}
			reusableView(title: Str.signInFailed, descr: "")

		case .myProfile:
			title = Str.myDevices
			reusableView(title: Str.appleHealthSelect, descr: Str.appleSelectMessage)
		case .myDevices:
			reusableView(title: Str.appleHealthImport, descr: Str.appleImportMessage)
		case .activate:
			reusableView(title: Str.synced, descr: "")
		default:
			return
		}
		switchScreen()
	}

	func reusableView(title: String, descr: String, image: String = "") {
		let appleHealthView = AppleHealthView(title: title, descr: descr, image: image)
		stackView.addArrangedSubview(appleHealthView)
		view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
	}

	func switchScreen() {
		leftButtonView()
		rightButtonView()
		nextButtonView()
	}

	func leftButtonView() {
		let attrText = Str.notNow.with(style: .regular20, andColor: .black, andLetterSpacing: 0.38)
		leftButton.setAttributedTitle(attrText, for: .normal)
		leftButton.isHidden = comingFrom != .myDevices
		leftButton.layer.cornerRadius = 20.0
		leftButton.layer.borderWidth = 1
		leftButton.layer.borderColor = UIColor.grey.cgColor
	}

	func rightButtonView() {
		let attrText = Str.activate.with(style: .regular20, andColor: .white, andLetterSpacing: 0.38)
		rightButton.setAttributedTitle(attrText, for: .normal)
		rightButton.isHidden = comingFrom != .myDevices
		rightButton.layer.cornerRadius = 20.0
		rightButton.backgroundColor = .grey
	}

	func nextButtonView() {
		let text = comingFrom != .activate ? Str.next.uppercased() : Str.done.uppercased()
		bottomView.isHidden = comingFrom == .myDevices
		nextButton.isHidden = comingFrom == .myDevices
		nextButton.backgroundColor = UIColor.next
		nextButton.setAttributedTitle(text.with(style: .regular17, andColor: .white, andLetterSpacing: 5), for: .normal)
		nextButton.refreshCorners(value: 0)
		nextButton.setupButton()
		nextButton.backgroundColor = comingFrom != .activate ? .next : .grey
		bottomView.backgroundColor = nextButton.backgroundColor
	}

	@IBAction func notNowTapped(_ sender: Any) {
		notNowAction?()
	}

	@IBAction func activateTapped(_ sender: Any) {
		activateAction?()
	}

	@objc func nextBtnTapped() {
		nextBtnAction?()
	}

	@objc func backBtnTapped() {
		backBtnAction?()
	}
}
