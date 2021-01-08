//
//  SelectChunkSizeViewController.swift
//  Alfred
//

import UIKit

class SelectChunkSizeViewController: BaseViewController {
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

	override func populateData() {
		super.populateData()
	}

	@IBAction func continueBtnTapped(_ sender: Any) {
		continueAction?(number)
	}
}

extension SelectChunkSizeViewController: UITextFieldDelegate {
	func textFieldDidEndEditing(_ textField: UITextField) {
		if let text = textField.text, let number = Int(text) {
			self.number = number
		}
	}
}
