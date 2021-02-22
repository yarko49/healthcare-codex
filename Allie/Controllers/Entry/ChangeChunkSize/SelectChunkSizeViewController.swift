//
//  SelectChunkSizeViewController.swift
//  Allie
//

import UIKit

class SelectChunkSizeViewController: BaseViewController {
	// MARK: - Coordinator Actions

	var continueAction: ((Int) -> Void)?
	@IBOutlet var textField: UITextField!

	var number = 4500
	override func setupView() {
		super.setupView()
		textField.delegate = self
	}

	@IBAction func continueButtonTapped(_ sender: Any) {
		continueAction?(number)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "SelectChunkSize"])
	}
}

extension SelectChunkSizeViewController: UITextFieldDelegate {
	func textFieldDidEndEditing(_ textField: UITextField) {
		if let text = textField.text, let number = Int(text) {
			self.number = number
		}
	}
}
