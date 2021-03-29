//
//  TextFieldEntryCell.swift
//  Allie
//
//  Created by Waqar Malik on 3/28/21.
//

import SkyFloatingLabelTextField
import UIKit

protocol TextFieldEntryCellDelegate: AnyObject {
	func textfieldCellDidFinishEditing(_ cell: TextFieldEntryCell)
	func textfieldCellValueDidChange(_ cell: TextFieldEntryCell)
}

class TextFieldEntryCell: UICollectionViewCell {
	weak var delegate: TextFieldEntryCellDelegate?

	let textField: SkyFloatingLabelTextField = {
		let view = SkyFloatingLabelTextField(frame: .zero)
		view.tintColor = .cursorOrange
		view.lineHeight = 1.0
		view.selectedLineHeight = 2.0
		return view
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		configureView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func configureView() {
		textField.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(textField)
		NSLayoutConstraint.activate([textField.topAnchor.constraint(equalToSystemSpacingBelow: contentView.safeAreaLayoutGuide.topAnchor, multiplier: 1.0),
		                             textField.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             contentView.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: textField.trailingAnchor, multiplier: 2.0),
		                             contentView.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: textField.bottomAnchor, multiplier: 1.0)])
		textField.delegate = self
	}

	var key: String?
	var value: String?
}

extension TextFieldEntryCell: UITextFieldDelegate {
	func textFieldDidEndEditing(_ textField: UITextField) {
		delegate?.textfieldCellDidFinishEditing(self)
	}

	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		value = (textField.text! as NSString).replacingCharacters(in: range, with: string)
		delegate?.textfieldCellValueDidChange(self)
		return true
	}
}
