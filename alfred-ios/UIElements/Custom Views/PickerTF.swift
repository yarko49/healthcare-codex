
import Foundation
import UIKit

class PickerTF: UIView {
	let contentXIBName = "PickerTF"

	// MARK: - IBOutlets

	@IBOutlet var textfield: UITextField!
	@IBOutlet var titleLbl: UILabel!
	@IBOutlet var contentView: UIView!
	@IBOutlet var lineView: UIView!

	var labelTitle: String? {
		didSet {
			titleLbl.attributedText = labelTitle?.with(style: .regular17, andColor: .grey, andLetterSpacing: -0.41)
		}
	}

	var tfText: String? {
		get {
			return textfield.text
		}
		set {
			textfield.attributedText = newValue?.with(style: .regular20, andColor: .lightGray, andLetterSpacing: -0.41)
		}
	}

	var state: State? {
		didSet {
			if state == .normal {
				titleLbl.textColor = .gray
				lineView.backgroundColor = .lightGray
			} else {
				titleLbl.textColor = .red
				lineView.backgroundColor = .red
			}
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

	convenience init(labelTitle: String, tfText: String, lineView: UIView) {
		self.init(frame: CGRect.zero)
		self.labelTitle = labelTitle
		self.tfText = tfText
		self.lineView = lineView
		commonInit()
	}

	func setupValues(labelTitle: String, text: String) {
		self.labelTitle = labelTitle
		tfText = text
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
		textfield.isEnabled = false
		textfield.tintColor = .orange
		textfield.textAlignment = .right
		titleLbl.attributedText = labelTitle?.with(style: .regular17, andColor: .grey, andLetterSpacing: -0.41)
		textfield.attributedText = tfText?.with(style: .regular20, andColor: .black, andLetterSpacing: -0.41)
		lineView.backgroundColor = .lightGrey
	}

	@objc func tapAction() {
		focus()
	}

	func focus() {
		textfield.becomeFirstResponder()
	}
}

extension PickerTF: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}

extension PickerTF {
	enum State {
		case normal, error
	}
}
