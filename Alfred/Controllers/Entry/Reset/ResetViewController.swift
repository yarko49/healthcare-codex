//
//  ResetViewController.swift
//  Alfred

import FirebaseAuth
import Foundation
import UIKit

class ResetViewController: BaseViewController {
	// MARK: - Coordinator Actions

	var backBtnAction: (() -> Void)?
	var nextAction: ((_ email: String?) -> Void)?

	// MARK: - IBOutlets

	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var saveButton: UIButton!
	@IBOutlet var resetLabel: UILabel!
	@IBOutlet var stackView: UIStackView!
	@IBOutlet var emailTextfieldView: TextfieldView!

	override func setupView() {
		super.setupView()
		navigationController?.navigationBar.isHidden = false
		let navBar = navigationController?.navigationBar
		navBar?.setBackgroundImage(UIImage(), for: .default)
		navBar?.shadowImage = UIImage()
		navBar?.isHidden = false
		navBar?.isTranslucent = false
		navBar?.layoutIfNeeded()
		title = "Reset Password"
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backBtnTapped))
		navigationItem.leftBarButtonItem?.tintColor = UIColor.black
		saveButton.addTarget(self, action: #selector(saveBtnTapped), for: .touchUpInside)
		setup()
	}

	func setup() {
		emailTextfieldView.setupValues(labelTitle: Str.emailAddress, text: "", textIsPassword: false)
		let attrText = Str.save.with(style: .regular17, andColor: UIColor.grey, andLetterSpacing: 3)
		saveButton.setAttributedTitle(attrText, for: .normal)
		saveButton.layer.cornerRadius = 28.5
		saveButton.backgroundColor = UIColor.white
		saveButton.layer.borderWidth = 2.0
		saveButton.layer.borderColor = UIColor.grey.cgColor
		resetLabel.attributedText = Str.resetMessage.with(style: .regular17, andColor: .lightGray, andLetterSpacing: -0.408)
		resetLabel.numberOfLines = 0
	}

	@IBAction func saveBtnTapped(_ sender: Any) {
		nextAction?(emailTextfieldView.tfText)
	}

	@objc func backBtnTapped() {
		backBtnAction?()
	}
}
