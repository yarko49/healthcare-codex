//
//  TextfieldView.swift
//  Alfred

import Foundation
import UIKit

class TextfieldView: UIView {
	let contentXIBName = "TextfieldView"

	// MARK: - IBOutlets

	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var textfield: UITextField!
	@IBOutlet var contentView: UIView!

	var textIsPassword: Bool = false {
		didSet {
			textfield.isSecureTextEntry = textIsPassword
		}
	}

	var labelTitle: String? {
		didSet {
			titleLabel.attributedText = labelTitle?.with(style: .regular17, andColor: .lightGrey, andLetterSpacing: -0.078)
		}
	}

	var tfText: String? {
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
		self.labelTitle = labelTitle
		self.tfText = tfText
		self.textIsPassword = textIsPassword
		commonInit()
	}

	func setupValues(labelTitle: String, text: String, textIsPassword: Bool) {
		self.labelTitle = labelTitle
		tfText = text
		self.textIsPassword = textIsPassword
		setup()
	}

	func commonInit() {
		Bundle.main.loadNibNamed(contentXIBName, owner: self, options: nil)
		contentView.fixInView(self)
		setup()
	}

	private func setup() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
		addGestureRecognizer(tap)
		textfield.delegate = self
		textfield.tintColor = .cursorOrange
		titleLabel.attributedText = labelTitle?.with(style: .regular17, andColor: .lightGrey, andLetterSpacing: -0.078)
		textfield.attributedText = tfText?.with(style: .regular20, andColor: .black, andLetterSpacing: 0.38)
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
