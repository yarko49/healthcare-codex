//
//  SelectChunkSizeViewController.swift
//  Allie
//

import UIKit

class SelectChunkSizeViewController: BaseViewController {
	// MARK: - Coordinator Actions

	var continueAction: ((Int) -> Void)?

	override func setupView() {
		super.setupView()
		textField.delegate = self
		continueButton.addTarget(self, action: #selector(continueButtonTapped(_:)), for: .touchUpInside)

		view.addSubview(stackView)
		NSLayoutConstraint.activate([stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 5.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 5.0),
		                             stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)])
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(textField)
		stackView.addArrangedSubview(continueButton)
	}

	@IBAction func continueButtonTapped(_ sender: Any) {
		continueAction?(UserDefaults.standard.healthKitUploadChunkSize)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "SelectChunkSize"])
	}

	let titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.adjustsFontForContentSizeCategory = true
		label.font = UIFont.preferredFont(forTextStyle: .body)
		label.text = NSLocalizedString("SELECT_CHUNK_SIZE", comment: "Select Chunk Size:")
		return label
	}()

	let textField: UITextField = {
		let textField = UITextField(frame: .zero)
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.borderStyle = .roundedRect
		textField.text = String(UserDefaults.standard.healthKitUploadChunkSize)
		textField.clearButtonMode = .whileEditing
		textField.keyboardType = .numberPad
		return textField
	}()

	let continueButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle(NSLocalizedString("CONTINUE", comment: "Continue"), for: .normal)
		return button
	}()

	private let stackView: UIStackView = {
		let stackView = UIStackView(frame: .zero)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 20.0
		stackView.distribution = .fill
		stackView.alignment = .fill
		return stackView
	}()
}

extension SelectChunkSizeViewController: UITextFieldDelegate {
	func textFieldDidEndEditing(_ textField: UITextField) {
		if let text = textField.text, let chunkSize = Int(text) {
			UserDefaults.standard.healthKitUploadChunkSize = chunkSize
		}
	}
}
