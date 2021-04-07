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
		button.layer.cornerRadius = 4.0
		button.layer.cornerCurve = .continuous
		button.setTitle(NSLocalizedString("MALE", comment: "Male"), for: .normal)
		return button
	}()

	let femaleButton: UIButton = {
		let button = UIButton(type: .system)
		button.layer.cornerRadius = 4.0
		button.layer.cornerCurve = .continuous
		button.setTitle(NSLocalizedString("FEMALE", comment: "Female"), for: .normal)
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
		alignment = .center
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
			maleButton.backgroundColor = .activityBackground
			maleButton.setTitleColor(.white, for: .normal)
			femaleButton.setTitleColor(.activityBackground, for: .normal)
			femaleButton.backgroundColor = .white
		} else if sex == .female {
			maleButton.backgroundColor = .white
			maleButton.setTitleColor(.activityBackground, for: .normal)
			femaleButton.setTitleColor(.white, for: .normal)
			femaleButton.backgroundColor = .activityBackground
		}
	}
}
