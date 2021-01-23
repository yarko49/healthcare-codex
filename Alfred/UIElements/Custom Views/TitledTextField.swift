//
//  TitledTextField.swift
//  Alfred
//
//  Created by Waqar Malik on 1/20/21.
//

import UIKit

class TitledTextField: UIStackView {
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureView()
	}

	@available(*, unavailable)
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	let titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .lightGrey
		label.heightAnchor.constraint(equalToConstant: 21.0).isActive = true
		return label
	}()

	let textfield: UITextField = {
		let view = UITextField(frame: .zero)
		view.borderStyle = .none
		view.font = UIFont.systemFont(ofSize: 20.0)
		view.tintColor = .cursorOrange
		view.translatesAutoresizingMaskIntoConstraints = false
		view.heightAnchor.constraint(equalToConstant: 26.0).isActive = true
		return view
	}()

	private let horizontalBar: UIView = {
		let view = UIView(frame: .zero)
		view.backgroundColor = .lightGrey
		view.translatesAutoresizingMaskIntoConstraints = false
		view.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
		return view
	}()

	var isSecureTextEntry: Bool {
		get {
			textfield.isSecureTextEntry
		}
		set {
			textfield.isSecureTextEntry = newValue
		}
	}

	var title: String? {
		get {
			titleLabel.text
		}
		set {
			titleLabel.text = newValue
		}
	}

	var text: String? {
		get {
			textfield.text
		}
		set {
			textfield.text = newValue
		}
	}

	func configureView() {
		axis = .vertical
		spacing = 5.0
		distribution = .fill
		alignment = .fill

		addArrangedSubview(titleLabel)
		addArrangedSubview(textfield)
		addArrangedSubview(horizontalBar)
		textfield.delegate = self
	}

	override func becomeFirstResponder() -> Bool {
		textfield.becomeFirstResponder()
		return super.becomeFirstResponder()
	}

	override func resignFirstResponder() -> Bool {
		textfield.resignFirstResponder()
		return super.resignFirstResponder()
	}
}

extension TitledTextField: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}
