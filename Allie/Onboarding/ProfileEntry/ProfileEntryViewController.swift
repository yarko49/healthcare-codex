//
//  ProfileEntryViewController.swift
//  Allie
//
//  Created by Waqar Malik on 4/4/21.
//

import CareKitStore
import UIKit

class ProfileEntryViewController: BaseViewController {
	enum Constants {
		static let heightInInches: Int = 66
		static let weightInPounds: Int = 150
		static let inchesToMeters: Double = 0.0254
		static let poundsToKilograms: Double = 0.4535924
	}

	var doneAction: Coordinable.ActionHandler?
	static let controlHeight: CGFloat = 50.0
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .onboardingBackground
		mainStackView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(mainStackView)
		NSLayoutConstraint.activate([mainStackView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 5.0),
		                             mainStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: mainStackView.trailingAnchor, multiplier: 2.0)])
		mainStackView.addArrangedSubview(nameTextField)
		mainStackView.addArrangedSubview(dateOfBirthView)
		mainStackView.addArrangedSubview(gendePickerView)
		mainStackView.addArrangedSubview(buttonStackView)
		buttonStackView.addArrangedSubview(heightButton)
		buttonStackView.addArrangedSubview(weightButton)
		mainStackView.addArrangedSubview(nextButton)
		pickerStackView.translatesAutoresizingMaskIntoConstraints = false
		mainStackView.addArrangedSubview(pickerStackView)
		pickerStackView.addArrangedSubview(heightPickerView)
		pickerStackView.addArrangedSubview(weightPickerView)
		heightButton.button.addTarget(self, action: #selector(showHeightPicker), for: .touchUpInside)
		weightButton.button.addTarget(self, action: #selector(showWeightPicker), for: .touchUpInside)
		nextButton.addTarget(self, action: #selector(done), for: .touchUpInside)
		configureValues()
	}

	var fullName: String? {
		get {
			nameTextField.textField.text
		}
		set {
			nameTextField.textField.text = newValue
		}
	}

	var heightInInches: Int = Constants.heightInInches {
		didSet {
			let heightInMeters = Double(heightInInches) * Constants.inchesToMeters
			let heightString = heightFormatter.string(fromMeters: heightInMeters)
			heightButton.button.setTitle(heightString, for: .normal)
		}
	}

	var weightInPounds: Int = Constants.weightInPounds {
		didSet {
			let kilograms = Double(weightInPounds) * Constants.poundsToKilograms
			let weightString = massFormatter.string(fromKilograms: kilograms)
			weightButton.button.setTitle(weightString, for: .normal)
		}
	}

	var dateOfBirth = Date() {
		didSet {
			dateOfBirthView.datePicker.date = dateOfBirth
		}
	}

	var sex: OCKBiologicalSex {
		get {
			gendePickerView.sex
		}
		set {
			gendePickerView.sex = newValue
		}
	}

	let nameTextField: CodexTextField = {
		let textField = CodexTextField(frame: .zero)
		textField.titleLabel.text = NSLocalizedString("YOUR_FULL_NAME", comment: "Your full name")
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.heightAnchor.constraint(equalToConstant: controlHeight).isActive = true
		return textField
	}()

	let dateOfBirthView: DatePickerView = {
		let view = DatePickerView(frame: .zero)
		view.titleLabel.text = NSLocalizedString("DATE_OF_BIRTH", comment: "Date of birth")
		view.translatesAutoresizingMaskIntoConstraints = false
		view.heightAnchor.constraint(equalToConstant: controlHeight).isActive = true
		return view
	}()

	let gendePickerView: GenderPickerView = {
		let view = GenderPickerView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.heightAnchor.constraint(equalToConstant: controlHeight).isActive = true
		return view
	}()

	let heightButton: ButtonView = {
		let button = ButtonView(frame: .zero)
		button.titleLabel.text = NSLocalizedString("HEIGHT", comment: "Height")
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	let weightButton: ButtonView = {
		let button = ButtonView(frame: .zero)
		button.titleLabel.text = NSLocalizedString("WEIGHT", comment: "Weight")
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	private let mainStackView: UIStackView = {
		let view = UIStackView(frame: .zero)
		view.axis = .vertical
		view.spacing = 10.0
		view.distribution = .fill
		view.alignment = .fill
		return view
	}()

	private let buttonStackView: UIStackView = {
		let view = UIStackView(frame: .zero)
		view.axis = .horizontal
		view.spacing = 10.0
		view.distribution = .fillEqually
		view.alignment = .center
		view.translatesAutoresizingMaskIntoConstraints = false
		view.heightAnchor.constraint(equalToConstant: controlHeight).isActive = true
		return view
	}()

	let massFormatter: MassFormatter = {
		let formatter = MassFormatter()
		formatter.isForPersonMassUse = true
		formatter.unitStyle = .medium
		return formatter
	}()

	let heightFormatter: LengthFormatter = {
		let formatter = LengthFormatter()
		formatter.isForPersonHeightUse = true
		formatter.unitStyle = .medium
		return formatter
	}()

	let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return formatter
	}()

	func configureValues() {
		nameTextField.textField.delegate = self
		fixLabelsInPlace(with: heightPickerView)
		fixLabelsInPlace(with: weightPickerView)
		let weightIndex = weightDataInPounds.first { value in
			value == weightInPounds
		}
		let feetIndex = heightData[0].first { value in
			value == heightInInches / 12
		}
		let inchesIndex = heightData[1].first { value in
			value == heightInInches % 12
		}

		heightPickerView.selectRow(feetIndex ?? 2, inComponent: 0, animated: false)
		heightPickerView.selectRow(inchesIndex ?? 6, inComponent: 1, animated: false)
		weightPickerView.selectRow(weightIndex ?? 125, inComponent: 0, animated: false)
		hideAllPicker()
	}

	lazy var heightPickerView: UIPickerView = {
		let picker = UIPickerView(frame: .zero)
		picker.translatesAutoresizingMaskIntoConstraints = false
		picker.dataSource = self
		picker.delegate = self
		return picker
	}()

	lazy var weightPickerView: UIPickerView = {
		let picker = UIPickerView(frame: .zero)
		picker.dataSource = self
		picker.delegate = self
		picker.translatesAutoresizingMaskIntoConstraints = false
		return picker
	}()

	@IBAction func showHeightPicker() {
		nameTextField.textField.resignFirstResponder()
		weightPickerView.isHidden = true
		heightPickerView.isHidden = false
	}

	@IBAction func showWeightPicker() {
		nameTextField.textField.resignFirstResponder()
		heightPickerView.isHidden = true
		weightPickerView.isHidden = false
	}

	@IBAction func done() {
		doneAction?()
	}

	func hideAllPicker() {
		heightPickerView.isHidden = true
		weightPickerView.isHidden = true
	}

	private let pickerStackView: UIStackView = {
		let view = UIStackView(frame: .zero)
		view.axis = .vertical
		view.spacing = 8.0
		view.alignment = .fill
		view.distribution = .fill
		return view
	}()

	let nextButton: UIButton = {
		let button = UIButton(type: .custom)
		button.backgroundColor = .grey
		button.layer.cornerRadius = 4.0
		button.layer.cornerCurve = .continuous
		let title = Str.done.uppercased()
		let attributes: [NSAttributedString.Key: Any] = [.kern: 5.0, .foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 17.0, weight: .semibold)]
		let attributedText = NSAttributedString(string: title, attributes: attributes)
		button.setAttributedTitle(attributedText, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.heightAnchor.constraint(equalToConstant: controlHeight).isActive = true
		return button
	}()

	let heightData = [Array(3 ... 8), Array(0 ... 12)]
	var weightDataInPounds = Array(25 ... 300)

	private func fixLabelsInPlace(with picker: UIPickerView) {
		let font = UIFont.systemFont(ofSize: 12.0, weight: .bold)
		let fontSize: CGFloat = font.pointSize
		let componentWidth: CGFloat = view.frame.width / CGFloat(picker.numberOfComponents)
		let yPos = (picker.frame.size.height / 2) - (fontSize / 2)

		if picker == heightPickerView {
			let label = UILabel(frame: CGRect(x: componentWidth * 0.625, y: yPos, width: componentWidth * 0.4, height: fontSize))
			label.font = font
			label.textAlignment = .left
			label.text = "ft"
			label.textColor = .black
			picker.addSubview(label)

			let label2 = UILabel(frame: CGRect(x: componentWidth * 1.6, y: yPos, width: componentWidth * 0.4, height: fontSize))
			label2.font = font
			label2.textAlignment = .left
			label2.text = "in"
			label2.textColor = .black
			picker.addSubview(label2)
		} else if picker == weightPickerView {
			let label = UILabel(frame: CGRect(x: componentWidth * 0.6, y: yPos, width: componentWidth * 0.4, height: fontSize))
			label.font = font
			label.textAlignment = .left
			label.text = Str.lb
			label.textColor = .black
			picker.addSubview(label)
		}
	}
}

extension ProfileEntryViewController: UIPickerViewDataSource, UIPickerViewDelegate {
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		if pickerView == heightPickerView {
			return 2
		} else {
			return 1
		}
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		var data = 0
		if pickerView == heightPickerView {
			data = heightData[component].count
		} else if pickerView == weightPickerView {
			data = weightDataInPounds.count
		}
		return data
	}

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		var rowData: String = ""

		if pickerView == heightPickerView {
			rowData = "\(heightData[component][row])"
		} else if pickerView == weightPickerView {
			rowData = "\(weightDataInPounds[row])"
		}
		return rowData
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if pickerView == weightPickerView {
			weightInPounds = weightDataInPounds[row]
		} else if pickerView == heightPickerView {
			let feet = heightData[0][pickerView.selectedRow(inComponent: 0)]
			let inches = heightData[1][pickerView.selectedRow(inComponent: 1)]
			heightInInches = feet * 12 + inches
		}
	}
}

extension ProfileEntryViewController: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		textField.becomeFirstResponder()
		hideAllPicker()
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}
