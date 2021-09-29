//
//  ProfileEntryViewController.swift
//  Allie
//
//  Created by Waqar Malik on 4/4/21.
//

import CareKitStore
import Combine
import SkyFloatingLabelTextField
import UIKit

class ProfileEntryViewController: SignupBaseViewController {
	enum Constants {
		static let heightInInches: Int = 66
		static let weightInPounds: Int = 150
		static let inchesToMeters: Double = 0.0254
		static let poundsToKilograms: Double = 0.4535924
	}

	var patient: CHPatient? {
		didSet {
			configureValues()
		}
	}

	var doneAction: AllieActionHandler?
	static var controlHeight: CGFloat = 48.0
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .allieWhite
		var viewTopOffset: CGFloat = controllerViewMode == .onboarding ? 2.0 : 1.0
		var bottomButtonOffset: CGFloat = 2.0
		if UIScreen.main.bounds.height <= 667 {
			Self.controlHeight = 45.0
			mainStackView.spacing = 5.0
			viewTopOffset = 0.0
			bottomButtonOffset = 0.0
		}
		configureValidation()
		[namesStackView, firstNameTextField, lastNameTextField, mainStackView].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}
		view.addSubview(mainStackView)
		let viewTopAnchor = controllerViewMode == .onboarding ? labekStackView.bottomAnchor : view.safeAreaLayoutGuide.topAnchor
		NSLayoutConstraint.activate([mainStackView.topAnchor.constraint(equalToSystemSpacingBelow: viewTopAnchor, multiplier: viewTopOffset),
		                             mainStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: mainStackView.trailingAnchor, multiplier: 2.0)])
		namesStackView.addArrangedSubview(firstNameTextField)
		namesStackView.addArrangedSubview(lastNameTextField)
		mainStackView.addArrangedSubview(namesStackView)
		if controllerViewMode != .onboarding {
			mainStackView.addArrangedSubview(emailTextField)
		}
		mainStackView.addArrangedSubview(dateOfBirthView)
		mainStackView.addArrangedSubview(buttonStackView)
		buttonStackView.addArrangedSubview(heightButton)
		buttonStackView.addArrangedSubview(weightButton)
		mainStackView.addArrangedSubview(gendePickerView)
		heightButton.button.addTarget(self, action: #selector(showHeightPicker), for: .touchUpInside)
		weightButton.button.addTarget(self, action: #selector(showWeightPicker), for: .touchUpInside)

		view.addSubview(bottomButton)
		NSLayoutConstraint.activate([bottomButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: bottomButton.trailingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: bottomButton.bottomAnchor, multiplier: bottomButtonOffset)])
		bottomButton.addTarget(self, action: #selector(save(_:)), for: .touchUpInside)
		bottomButton.setTitle(doneButtonTitle, for: .normal)
		bottomButton.backgroundColor = .allieGray
		firstNameTextField.addTarget(self, action: #selector(firstNameDidChange(_:)), for: .editingChanged)
		lastNameTextField.addTarget(self, action: #selector(lastNameDidChange(_:)), for: .editingChanged)
		configureValues()
	}

	private func configureValidation() {
		validName
			.receive(on: RunLoop.main)
			.assign(to: \.isEnabled, on: bottomButton)
			.store(in: &cancellables)
		bottomButton.publisher(for: \.isEnabled)
			.receive(on: RunLoop.main)
			.map { $0 }
			.sink { enabled in
				self.bottomButton.backgroundColor = enabled ? .allieGray : .allieGray.withAlphaComponent(0.5)
			}.store(in: &cancellables)
	}

	var doneButtonTitle: String? = NSLocalizedString("NEXT", comment: "Next")

	@Published var firstName: String = ""
	@Published var lastName: String = ""

	var name: PersonNameComponents {
		get {
			var name = PersonNameComponents()
			name.familyName = lastName
			name.givenName = firstName
			return name
		}
		set {
			lastName = newValue.familyName ?? ""
			firstName = newValue.givenName ?? ""
		}
	}

	var validName: AnyPublisher<Bool, Never> {
		validFirstName.combineLatest(validLastName) { validFirstName, validLastName in
			validFirstName && validLastName
		}.eraseToAnyPublisher()
	}

	var validFirstName: AnyPublisher<Bool, Never> {
		$firstName
			.debounce(for: 0.2, scheduler: RunLoop.main)
			.removeDuplicates()
			.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
			.map { $0.count > 1 ? true : false }
			.eraseToAnyPublisher()
	}

	var validLastName: AnyPublisher<Bool, Never> {
		$lastName
			.debounce(for: 0.2, scheduler: RunLoop.main)
			.removeDuplicates()
			.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
			.map { $0.count > 1 ? true : false }
			.eraseToAnyPublisher()
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

	var dateOfBirth: Date {
		get {
			dateOfBirthView.datePicker.date
		}
		set {
			dateOfBirthView.datePicker.date = newValue
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

	private class func createNameTextField(placeholder: String, isRequired: Bool = false) -> SkyFloatingLabelTextField {
		let textField = SkyFloatingLabelTextField(frame: .zero)
		textField.lineHeight = 1.0
		textField.selectedLineHeight = 1.0
		textField.lineColor = .allieSeparator
		textField.selectedLineColor = .allieSeparator
		textField.placeholder = placeholder
		textField.selectedTitleColor = .allieSeparator
		textField.selectedTitle = placeholder + (isRequired ? "*" : "")
		textField.autocorrectionType = .no
		textField.keyboardType = .default
		textField.autocapitalizationType = .none
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.heightAnchor.constraint(equalToConstant: controlHeight).isActive = true
		return textField
	}

	let namesStackView: UIStackView = {
		let view = UIStackView(frame: .zero)
		view.axis = .horizontal
		view.spacing = 8.0
		view.distribution = .fillEqually
		view.alignment = .fill
		return view
	}()

	@IBAction func firstNameDidChange(_ sender: UITextField) {
		firstName = sender.text ?? ""
	}

	@IBAction func lastNameDidChange(_ sender: UITextField) {
		lastName = sender.text ?? ""
	}

	let firstNameTextField: SkyFloatingLabelTextField = {
		createNameTextField(placeholder: NSLocalizedString("FIRST_NAME", comment: "First Name"), isRequired: true)
	}()

	let lastNameTextField: SkyFloatingLabelTextField = {
		createNameTextField(placeholder: NSLocalizedString("LAST_NAME", comment: "Last Name"), isRequired: false)
	}()

	lazy var emailTextField: SkyFloatingLabelTextField = {
		let textField = SkyFloatingLabelTextField(frame: .zero)
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
		textField.placeholder = NSLocalizedString("EMAIL", comment: "Email")
		textField.title = NSLocalizedString("EMAIL_ADDRESS", comment: "Email address")
		textField.errorColor = .systemRed
		textField.lineColor = .allieSeparator
		textField.selectedLineColor = .allieLighterGray
		textField.lineHeight = 1.0
		textField.selectedLineHeight = 1.0
		textField.textColor = .allieGray
		textField.keyboardType = .emailAddress
		textField.autocorrectionType = .no
		textField.autocapitalizationType = .none
		textField.selectedTitleColor = .allieLighterGray
		return textField
	}()

	let dateOfBirthView: DatePickerView = {
		let view = DatePickerView(frame: .zero)
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
		button.textField.placeholder = NSLocalizedString("HEIGHT", comment: "Height")
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	let weightButton: ButtonView = {
		let button = ButtonView(frame: .zero)
		button.textField.placeholder = NSLocalizedString("WEIGHT", comment: "Weight")
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
		firstNameTextField.delegate = self
		lastNameTextField.delegate = self
		firstNameTextField.text = patient?.name.givenName
		lastNameTextField.text = patient?.name.familyName
		firstName = patient?.name.givenName ?? ""
		lastName = patient?.name.familyName ?? ""
		emailTextField.text = patient?.profile.email
		heightInInches = patient?.profile.heightInInches ?? Constants.heightInInches
		weightInPounds = patient?.profile.weightInPounds ?? Constants.weightInPounds
		sex = patient?.sex ?? .male
		if let dob = patient?.birthday {
			dateOfBirth = dob
		}
	}

	@IBAction func showHeightPicker() {
		[firstNameTextField, lastNameTextField].forEach { textField in
			textField.resignFirstResponder()
		}
		let viewController = HeightPickerView()
		viewController.heightInInches = heightInInches
		viewController.delegate = self
		let navigationController = UINavigationController(rootViewController: viewController)
		navigationController.modalPresentationStyle = .overFullScreen
		navigationController.modalTransitionStyle = .crossDissolve
		showDetailViewController(navigationController, sender: self)
	}

	@IBAction func showWeightPicker() {
		[firstNameTextField, lastNameTextField].forEach { textField in
			textField.resignFirstResponder()
		}
		let viewController = WeightPickerView()
		viewController.weightInPounds = weightInPounds
		viewController.delegate = self
		let navigationController = UINavigationController(rootViewController: viewController)
		navigationController.modalPresentationStyle = .overFullScreen
		navigationController.modalTransitionStyle = .crossDissolve
		showDetailViewController(navigationController, sender: self)
	}

	@IBAction func save(_ sender: Any?) {
		doneAction?()
	}
}

extension ProfileEntryViewController: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		textField.becomeFirstResponder()
	}

	func textFieldDidEndEditing(_ textField: UITextField) {
		textField.resignFirstResponder()
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}

extension ProfileEntryViewController: WeightPickerViewDelegate {
	func weightPickerViewDidSave(_ picker: WeightPickerView) {
		weightInPounds = picker.weightInPounds
		picker.dismiss(animated: true, completion: nil)
	}
}

extension ProfileEntryViewController: HeightPickerViewDelegate {
	func heightPickerViewDidSave(_ picker: HeightPickerView) {
		heightInInches = picker.heightInInches
		picker.dismiss(animated: true, completion: nil)
	}
}
