//
//  AccountDetailsViewController.swift
//  Alfred
//

import Foundation
import UIKit

class AccountDetailsViewController: BaseViewController {
	// MARK: Coordinator Actions

	var backBtnAction: (() -> Void)?
	var resetPasswordAction: (() -> Void)?

	// MARK: - Properties

	var firstNameTextView = TextfieldView()
	var lastNameTextView = TextfieldView()
	var emailTextView = TextfieldView()

	// MARK: - IBOutlets

	@IBOutlet var textfieldStackView: UIStackView!
	@IBOutlet var passwordLbl: UILabel!
	@IBOutlet var passwordTF: UITextField!

	// MARK: - Setup

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		let backBtn = UIBarButtonItem(image: UIImage(named: "back")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(backBtnTapped))
		backBtn.tintColor = .black

		navigationItem.leftBarButtonItem = backBtn
	}

	override func setupView() {
		super.setupView()

		title = Str.accountDetails

		let firstName = DataContext.shared.userModel?.displayFirstName ?? ""
		let lastName = DataContext.shared.userModel?.displayLastName ?? ""
		guard let email = DataContext.shared.userModel?.email else { return }

		firstNameTextView.setupValues(labelTitle: Str.firstName, text: firstName, textIsPassword: false)
		lastNameTextView.setupValues(labelTitle: Str.lastName, text: lastName, textIsPassword: false)
		emailTextView.setupValues(labelTitle: Str.email, text: email, textIsPassword: false)

		textfieldStackView.addArrangedSubview(firstNameTextView)
		textfieldStackView.addArrangedSubview(lastNameTextView)
		textfieldStackView.addArrangedSubview(emailTextView)
		passwordTF.isUserInteractionEnabled = false
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func localize() {
		super.localize()

		passwordLbl.attributedText = Str.password.with(style: .regular13, andColor: .lightGrey, andLetterSpacing: -0.078)
		passwordTF.isSecureTextEntry = true
		passwordTF.attributedText = "1234567890".with(style: .regular17, andColor: .black, andLetterSpacing: 0.38)
	}

	override func populateData() {
		super.populateData()
	}

	// MARK: - Actions

	@objc func backBtnTapped() {
		backBtnAction?()
	}

	@IBAction func passwordResetTapped(_ sender: Any) {
		resetPasswordAction?()
	}
}
