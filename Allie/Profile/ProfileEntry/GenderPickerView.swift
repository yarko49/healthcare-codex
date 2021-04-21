//
//  GenderPickerView.swift
//  Allie
//
//  Created by Waqar Malik on 4/4/21.
//

import CareKitStore
import UIKit

class GenderPickerView: UIStackView {
	var sex: OCKBiologicalSex = .male {
		didSet {
			configureButtons()
		}
	}

	let maleButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
		button.setTitle(NSLocalizedString("MALE", comment: "Male"), for: .normal)
		button.setImage(UIImage(named: "icon-gender-male"), for: .normal)
		button.layer.borderColor = UIColor.allieSeparator.cgColor
		button.layer.borderWidth = 1.0
		return button
	}()

	let femaleButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
		button.setTitle(NSLocalizedString("FEMALE", comment: "Female"), for: .normal)
		button.setImage(UIImage(named: "icon-gender-female"), for: .normal)
		button.layer.borderColor = UIColor.allieSeparator.cgColor
		button.layer.borderWidth = 1.0
		return button
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		configureView()
	}

	@available(*, unavailable)
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func configureView() {
		axis = .horizontal
		distribution = .fillEqually
		alignment = .fill
		spacing = 10.0
		addArrangedSubview(maleButton)
		addArrangedSubview(femaleButton)

		maleButton.addTarget(self, action: #selector(didSelectMale(_:)), for: .touchUpInside)
		femaleButton.addTarget(self, action: #selector(didSelectFemale(_:)), for: .touchUpInside)
		configureButtons()
	}

	@IBAction func didSelectMale(_ sender: UIButton) {
		sex = .male
	}

	@IBAction func didSelectFemale(_ sender: UIButton) {
		sex = .female
	}

	private func configureButtons() {
		if sex == .male {
			maleButton.backgroundColor = .allieOrange
			maleButton.tintColor = .white
			maleButton.layer.borderColor = UIColor.allieOrange.cgColor
			femaleButton.backgroundColor = .white
			femaleButton.tintColor = .allieLighterGray
			femaleButton.layer.borderColor = UIColor.allieSeparator.cgColor
		} else if sex == .female {
			maleButton.backgroundColor = .white
			maleButton.tintColor = .allieLighterGray
			maleButton.layer.borderColor = UIColor.allieSeparator.cgColor
			femaleButton.backgroundColor = .allieOrange
			femaleButton.tintColor = .white
			femaleButton.layer.borderColor = UIColor.allieOrange.cgColor
		}
	}
}
