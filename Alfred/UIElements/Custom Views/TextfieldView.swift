//
//  TextfieldView.swift
//  Alfred

import Foundation
import UIKit

class TextfieldView: UIView {
	// MARK: - IBOutlets

	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var textfield: UITextField!
	@IBOutlet var contentView: UIView!

	var isSecureTextEntry: Bool {
		get {
			textfield?.isSecureTextEntry ?? false
		}
		set {
			textfield?.isSecureTextEntry = newValue
		}
	}

	var title: String? {
		get {
			titleLabel.text
		}
		set {
			titleLabel.attributedText = newValue?.with(style: .regular17, andColor: .lightGrey, andLetterSpacing: -0.078)
		}
	}

	var text: String? {
		get {
			textfield.text
		}
		set {
			textfield.attributedText = newValue?.with(style: .regular20, andColor: .black, andLetterSpacing: 0.38)
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}

	convenience init(labelTitle: String, tfText: String, textIsPassword: Bool) {
		self.init(frame: CGRect.zero)
		self.title = labelTitle
		self.text = tfText
		self.isSecureTextEntry = textIsPassword
		commonInit()
	}

	func setupValues(labelTitle: String, text: String, textIsPassword: Bool) {
		title = labelTitle
		self.text = text
		isSecureTextEntry = textIsPassword
		setup()
	}

	func commonInit() {
		isSecureTextEntry = false
		Bundle.main.loadNibNamed(Self.nibName, owner: self, options: nil)
		contentView.fixInView(self)
		setup()
	}

	private func setup() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
		addGestureRecognizer(tap)
		textfield.delegate = self
		textfield.tintColor = .cursorOrange
		titleLabel.attributedText = title?.with(style: .regular17, andColor: .lightGrey, andLetterSpacing: -0.078)
		textfield.attributedText = text?.with(style: .regular20, andColor: .black, andLetterSpacing: 0.38)
	}

	@objc func tapAction() {
		focus()
	}

	func focus() {
		textfield.becomeFirstResponder()
	}
}

extension TextfieldView: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}
