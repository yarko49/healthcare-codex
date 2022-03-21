//
//  GenderPickerView.swift
//  Allie
//
//  Created by Waqar Malik on 4/4/21.
//

import CareKitStore
import UIKit

class GenderPickerView: UIView {
	var sex: OCKBiologicalSex = .male {
		didSet {
			configureButtons()
		}
	}

	let genderStackView: UIStackView = {
		let genderStackView = UIStackView()
		genderStackView.translatesAutoresizingMaskIntoConstraints = false
		genderStackView.axis = .horizontal
		genderStackView.distribution = .fillEqually
		genderStackView.alignment = .fill
		genderStackView.spacing = 10.0
		return genderStackView
	}()

	let maleButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
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
		button.setImage(UIImage(named: "icon-gender-female"), for: .normal)
		button.layer.borderColor = UIColor.allieSeparator.cgColor
		button.layer.borderWidth = 1.0
		return button
	}()

	let sexAtBirthLabel: UILabel = {
		let sexAtBirthLabel = UILabel()
		sexAtBirthLabel.translatesAutoresizingMaskIntoConstraints = false
		sexAtBirthLabel.attributedText = "Sex assigned at birth".attributedString(style: .silkamedium14, foregroundColor: .allieLightGray)
		return sexAtBirthLabel
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
		backgroundColor = .clear
		[sexAtBirthLabel, genderStackView].forEach { addSubview($0) }
		NSLayoutConstraint.activate([sexAtBirthLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
		                             sexAtBirthLabel.leadingAnchor.constraint(equalTo: leadingAnchor)])
		[maleButton, femaleButton].forEach { genderStackView.addArrangedSubview($0) }
		NSLayoutConstraint.activate([genderStackView.topAnchor.constraint(equalTo: sexAtBirthLabel.bottomAnchor, constant: 8),
		                             genderStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
		                             genderStackView.heightAnchor.constraint(equalToConstant: 48),
		                             genderStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
		                             genderStackView.trailingAnchor.constraint(equalTo: trailingAnchor)])
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
			maleButton.backgroundColor = .mainBlue
			maleButton.tintColor = .white
			maleButton.setAttributedTitle(NSLocalizedString("MALE", comment: "Male").attributedString(style: .silkaregular16, foregroundColor: .white), for: .normal)
			maleButton.layer.borderColor = UIColor.mainBlue!.cgColor
			maleButton.setShadow()
			femaleButton.backgroundColor = .white
			femaleButton.tintColor = .allieLighterGray
			femaleButton.setAttributedTitle(NSLocalizedString("FEMALE", comment: "Female").attributedString(style: .silkaregular16, foregroundColor: .allieLighterGray), for: .normal)
			femaleButton.layer.borderColor = UIColor.allieSeparator.cgColor
			femaleButton.clearShadow()
		} else if sex == .female {
			maleButton.backgroundColor = .white
			maleButton.tintColor = .allieLighterGray
			maleButton.setAttributedTitle(NSLocalizedString("MALE", comment: "Male").attributedString(style: .silkaregular16, foregroundColor: .allieLighterGray), for: .normal)
			maleButton.layer.borderColor = UIColor.allieSeparator.cgColor
			maleButton.clearShadow()
			femaleButton.backgroundColor = .mainBlue
			femaleButton.tintColor = .white
			femaleButton.setAttributedTitle(NSLocalizedString("FEMALE", comment: "Female").attributedString(style: .silkaregular16, foregroundColor: .white), for: .normal)
			femaleButton.layer.borderColor = UIColor.mainBlue!.cgColor
			femaleButton.setShadow()
		}
	}
}
