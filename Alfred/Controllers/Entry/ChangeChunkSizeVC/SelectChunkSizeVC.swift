//
//  SelectChunkSizeVC.swift
//  alfred-ios
//

import UIKit

class SelectChunkSizeVC: BaseViewController {
	// MARK: - Coordinator Actions

	var continueAction: ((Int) -> Void)?

	// MARK: - Properties

	// MARK: - IBOutlets

	@IBOutlet var textField: UITextField!

	var number = 4500

	// MARK: - Setup

	override func setupView() {
		super.setupView()

		textField.delegate = self
	}

	override func localize() {
		super.localize()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func populateData() {
		super.populateData()
	}

	@IBAction func continueBtnTapped(_ sender: Any) {
		continueAction?(number)
	}
}

extension SelectChunkSizeVC: UITextFieldDelegate {
	func textFieldDidEndEditing(_ textField: UITextField) {
		if let text = textField.text, let number = Int(text) {
			self.number = number
		}
	}
}
