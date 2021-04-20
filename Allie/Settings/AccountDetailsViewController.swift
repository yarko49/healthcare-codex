//
//  AccountDetailsViewController.swift
//  Allie
//

import Foundation
import UIKit

class AccountDetailsViewController: BaseViewController {
	let stackView: UIStackView = {
		let view = UIStackView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.spacing = 20
		view.alignment = .fill
		view.distribution = .fill
		return view
	}()

	let firstNameTextView: TextfieldView = {
		let view = TextfieldView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.heightAnchor.constraint(equalToConstant: 64.0).isActive = true
		view.textfield.autocorrectionType = .no
		view.textfield.autocapitalizationType = .none
		return view
	}()

	let middleNameTextView: TextfieldView = {
		let view = TextfieldView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.heightAnchor.constraint(equalToConstant: 64.0).isActive = true
		view.textfield.autocorrectionType = .no
		view.textfield.autocapitalizationType = .none
		return view
	}()

	let lastNameTextView: TextfieldView = {
		let view = TextfieldView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.heightAnchor.constraint(equalToConstant: 64.0).isActive = true
		view.textfield.autocorrectionType = .no
		view.textfield.autocapitalizationType = .none
		return view
	}()

	let emailTextView: TextfieldView = {
		let view = TextfieldView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.heightAnchor.constraint(equalToConstant: 64.0).isActive = true
		view.textfield.keyboardType = .emailAddress
		view.textfield.autocorrectionType = .no
		view.textfield.autocapitalizationType = .none
		return view
	}()

	let saveButton: UIButton = {
		let button = UIButton(type: .system)
		button.layer.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
		button.backgroundColor = .allieButtons
		button.setTitleColor(.white, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
		button.setTitle(NSLocalizedString("UPDATE", comment: "Update"), for: .normal)
		return button
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(stackView)
		NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 4.0),
		                             stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 0.0)])
		stackView.addArrangedSubview(firstNameTextView)
		stackView.addArrangedSubview(middleNameTextView)
		stackView.addArrangedSubview(lastNameTextView)
		stackView.addArrangedSubview(emailTextView)

		view.addSubview(saveButton)
		NSLayoutConstraint.activate([saveButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 4.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: saveButton.trailingAnchor, multiplier: 4.0),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: saveButton.bottomAnchor, multiplier: 2.0)])
		saveButton.addTarget(self, action: #selector(update(_:)), for: .touchUpInside)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "AccountsDetailsView"])
	}

	// MARK: - Setup

	override func setupView() {
		super.setupView()
		title = Str.accountDetails
		let patient = AppDelegate.careManager.patient
		let firstName = patient?.name.givenName ?? ""
		let middleName = patient?.name.middleName ?? ""
		let lastName = patient?.name.familyName ?? ""
		let email = patient?.profile.email ?? Keychain.emailForLink ?? ""

		firstNameTextView.setupValues(labelTitle: Str.firstName, text: firstName, textIsPassword: false)
		middleNameTextView.setupValues(labelTitle: NSLocalizedString("MIDDLE_NAMES", comment: "Middle Name(s)"), text: middleName, textIsPassword: false)
		lastNameTextView.setupValues(labelTitle: Str.lastName, text: lastName, textIsPassword: false)
		emailTextView.setupValues(labelTitle: Str.email, text: email, textIsPassword: false)
	}

	@IBAction func update(_ sender: Any?) {
		guard var patient = AppDelegate.careManager.patient else {
			return
		}
		patient.name.givenName = firstNameTextView.text
		patient.name.middleName = middleNameTextView.text
		patient.name.familyName = lastNameTextView.text
		patient.profile.email = emailTextView.text

		hud.textLabel.text = NSLocalizedString("UPLOADING_DOTS", comment: "Uploading...")
		hud.detailTextLabel.text = NSLocalizedString("PROFILE", comment: "Profile")
		hud.show(in: view)
		APIClient.client.postPatient(patient: patient)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				self?.hud.dismiss(animated: false)
				switch completion {
				case .failure(let error):
					ALog.error("Unable to save profile", error: error)
					let title = NSLocalizedString("UNABLE_TO_UPDATE", comment: "Unable to update profile")
					self?.showAlert(title: title, message: error.localizedDescription)
				case .finished:
					break
				}
			} receiveValue: { [weak self] value in
				if let patient = value.patients.first {
					AppDelegate.careManager.patient = patient
				}
				self?.navigationController?.popViewController(animated: true)
			}.store(in: &cancellables)
	}

	func showAlert(title: String?, message: String?) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Ok"), style: .default) { _ in
		}
		alertController.addAction(okAction)
		navigationController?.showDetailViewController(alertController, sender: self)
	}
}
