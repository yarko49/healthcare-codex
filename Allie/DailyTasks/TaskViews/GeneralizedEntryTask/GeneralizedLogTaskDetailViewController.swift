//
//  GeneralizedLogTaskDetailViewController.swift
//  Allie
//
//  Created by Waqar Malik on 7/5/21.
//

import CareKitStore
import HealthKit
import UIKit

enum GeneralizedEntryTaskError: Error {
	case missing(String)
	case invalid(String)
}

class GeneralizedLogTaskDetailViewController: UIViewController {
	var healthKitSampleHandler: AllieHealthKitSampleHandler?
	var cancelAction: AllieActionHandler?
	var deleteAction: AllieActionHandler?

	let entryTaskView: GeneralizedLogTaskDetailView = {
		let view = GeneralizedLogTaskDetailView()
		return view
	}()

	var outcomeValue: OCKOutcomeValue?
	var task: OCKHealthKitTask?

	let headerView: EntryTaskSectionHeaderView = {
		let view = EntryTaskSectionHeaderView(frame: .zero)
		view.button.setImage(UIImage(systemName: "multiply"), for: .normal)
		view.button.backgroundColor = .allieLighterGray
		view.textLabel.text = "Insulin"
		view.detailTextLabel.text = "Instructions"
		view.imageView.image = UIImage(named: "icon-insulin")
		view.heightAnchor.constraint(equalToConstant: EntryTaskSectionHeaderView.height).isActive = true
		return view
	}()

	let footerView: EntryTaskSectionFooterView = {
		let view = EntryTaskSectionFooterView(frame: .zero)
		view.saveButton.setTitle(NSLocalizedString("SAVE", comment: "Save"), for: .normal)
		view.heightAnchor.constraint(equalToConstant: EntryTaskSectionFooterView.height).isActive = true
		return view
	}()

	private(set) var identifiers: [String] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .black.withAlphaComponent(0.6)
		entryTaskView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(entryTaskView)
		NSLayoutConstraint.activate([entryTaskView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 10.0),
		                             entryTaskView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 15.0 / 8.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: entryTaskView.trailingAnchor, multiplier: 15.0 / 8.0)])
		headerView.translatesAutoresizingMaskIntoConstraints = false
		headerView.delegate = self
		entryTaskView.insertArrangedSubview(headerView, at: 0)
		let count = entryTaskView.arrangedSubviews.count
		footerView.translatesAutoresizingMaskIntoConstraints = false
		footerView.delegate = self
		entryTaskView.insertArrangedSubview(footerView, at: count)
		configureView(task: task)
	}

	private func addView(identifier: String, at index: Int) {
		if identifier == SegmentedEntryView.reuseIdentifier {
			let cell = entryTaskView.dequeueCell(identifier: identifier, at: index) as? SegmentedEntryView
			configure(segementedEntryView: cell)
		} else if identifier == TimeValueEntryView.reuseIdentifier {
			let cell = entryTaskView.dequeueCell(identifier: identifier, at: index) as? TimeValueEntryView
			configure(timeValueEntryView: cell)
		} else if identifier == MultiValueEntryView.reuseIdentifier {
			let cell = entryTaskView.dequeueCell(identifier: identifier, at: index) as? MultiValueEntryView
			if task?.healthKitLinkage.quantityIdentifier == .bloodPressureDiastolic || task?.healthKitLinkage.quantityIdentifier == .bloodPressureSystolic {
				configure(bloodPressureEntryView: cell)
			} else {
				configure(multiValueEntryView: cell)
			}
		}
	}

	private func configure(segementedEntryView cell: SegmentedEntryView?) {
		guard let cell = cell else {
			return
		}
		var titles: [String] = []
		if task?.healthKitLinkage.quantityIdentifier == .insulinDelivery {
			titles = [HKInsulinDeliveryReason.bolus, HKInsulinDeliveryReason.basal].compactMap { reason in
				reason.title
			}
		} else if task?.healthKitLinkage.quantityIdentifier == .bloodGlucose {
			titles = [CHBloodGlucoseMealTime.fasting, CHBloodGlucoseMealTime.preprandial, CHBloodGlucoseMealTime.postprandial].map { mealTime in
				mealTime.title
			}
		}
		cell.configure(titles: titles)
		cell.delegate = self
	}

	private func configure(timeValueEntryView cell: TimeValueEntryView?) {
		guard let cell = cell else {
			return
		}
		cell.translatesAutoresizingMaskIntoConstraints = false
		let unit = task?.healthKitLinkage.unit
		let elements = task?.schedule.elements
		let targetValue = elements?.first?.targetValues.first
		let placeholder = targetValue?.integerValue ?? 100
		var value: String?
		if let intValue = outcomeValue?.integerValue {
			value = "\(intValue)"
		} else if let doubleValue = outcomeValue?.doubleValue {
			value = "\(Int(doubleValue))"
		}
		let date = outcomeValue?.createdDate
		cell.configure(placeHolder: "\(placeholder)", value: value, unitTitle: unit?.displayUnitSting ?? "", date: date, isActive: true)
	}

	private func configure(multiValueEntryView cell: MultiValueEntryView?) {
		cell?.translatesAutoresizingMaskIntoConstraints = false
		cell?.heightAnchor.constraint(equalToConstant: MultiValueEntryView.height).isActive = true
		guard let targetValues = task?.schedule.elements.first?.targetValues else {
			return
		}
		cell?.leadingEntryView.isHidden = true
		cell?.trailingEntryView.isHidden = true
		for (index, value) in targetValues.enumerated() {
			if index == 0 {
				cell?.leadingEntryView.isHidden = false
				cell?.leadingEntryView.textField.placeholder = "\(value.integerValue ?? 0)"
				cell?.leadingEntryView.textLabel.text = value.units
				cell?.leadingEntryView.textField.becomeFirstResponder()
			} else if index == 1 {
				cell?.trailingEntryView.isHidden = false
				cell?.trailingEntryView.textField.placeholder = "\(value.integerValue ?? 0)"
				cell?.trailingEntryView.textLabel.text = value.units
			} else {
				break
			}
		}
	}

	private func configure(bloodPressureEntryView cell: MultiValueEntryView?) {
		cell?.translatesAutoresizingMaskIntoConstraints = false
		cell?.heightAnchor.constraint(equalToConstant: MultiValueEntryView.height).isActive = true
		guard let targetValues = task?.schedule.elements.first?.targetValues else {
			return
		}
		cell?.leadingEntryView.isHidden = false
		cell?.trailingEntryView.isHidden = false
		if targetValues[0].kind == "systolic" {
			cell?.leadingEntryView.textField.placeholder = "\(targetValues[0].integerValue ?? 0)"
			cell?.leadingEntryView.textLabel.text = targetValues[0].units
			cell?.leadingEntryView.textField.becomeFirstResponder()
			cell?.trailingEntryView.textField.placeholder = "\(targetValues[1].integerValue ?? 0)"
			cell?.trailingEntryView.textLabel.text = targetValues[1].units
		} else {
			cell?.leadingEntryView.textField.placeholder = "\(targetValues[1].integerValue ?? 0)"
			cell?.leadingEntryView.textLabel.text = targetValues[1].units
			cell?.leadingEntryView.textField.becomeFirstResponder()
			cell?.trailingEntryView.textField.placeholder = "\(targetValues[0].integerValue ?? 0)"
			cell?.trailingEntryView.textLabel.text = targetValues[0].units
		}
	}

	private func configureView(task: OCKHealthKitTask?) {
		headerView.textLabel.text = task?.title
		headerView.detailTextLabel.text = task?.instructions
		let dataType = task?.healthKitLinkage.quantityIdentifier.dataType
		headerView.imageView.image = dataType?.image

		guard let linkage = task?.healthKitLinkage, let identifiers = linkage.quantityIdentifier.taskViews else {
			return
		}
		self.identifiers = identifiers
		for (index, identifier) in self.identifiers.enumerated() {
			addView(identifier: identifier, at: index)
		}
		footerView.deleteButton.isHidden = outcomeValue == nil
	}

	func createHealthKitSample() throws -> HKSample {
		guard let quantityIdentifier = task?.healthKitLinkage.quantityIdentifier else {
			throw GeneralizedEntryTaskError.missing("Quantity Identifier")
		}

		let sample: HKSample
		if quantityIdentifier == .insulinDelivery {
			sample = try createInsulinSample()
		} else if quantityIdentifier == .bloodGlucose {
			sample = try createBloodGlucoseSample()
		} else if quantityIdentifier == .bodyMass {
			sample = try createBodyMassSample()
		} else if quantityIdentifier == .bloodPressureDiastolic || quantityIdentifier == .bloodPressureSystolic {
			sample = try createBloodPressureSample()
		} else {
			throw GeneralizedEntryTaskError.invalid("Quantity Identifier")
		}
		return sample
	}

	func createInsulinSample() throws -> HKSample {
		guard let unitView = entryTaskView.entryView(forIdentifier: TimeValueEntryView.reuseIdentifier) as? TimeValueEntryView, let valueString = unitView.value, !valueString.isEmpty else {
			throw GeneralizedEntryTaskError.missing(NSLocalizedString("HEALTHKIT_ERROR_SAVE_DATA.message", comment: "Please enter correct value and then save."))
		}

		guard let segementedView = entryTaskView.entryView(forIdentifier: SegmentedEntryView.reuseIdentifier) as? SegmentedEntryView else {
			throw GeneralizedEntryTaskError.invalid("Invalid Context")
		}

		guard let value = Double(valueString) else {
			throw GeneralizedEntryTaskError.invalid("Value of invalid type")
		}

		let date = unitView.date
		let selectedIndex = segementedView.segementedControl.selectedSegmentIndex
		let reason: HKInsulinDeliveryReason = selectedIndex == 0 ? .bolus : .basal
		let sample = HKDiscreteQuantitySample(insulinUnits: value, startDate: date, reason: reason)
		return sample
	}

	func createBloodGlucoseSample() throws -> HKSample {
		guard let unitView = entryTaskView.entryView(forIdentifier: TimeValueEntryView.reuseIdentifier) as? TimeValueEntryView, let valueString = unitView.value, !valueString.isEmpty else {
			throw GeneralizedEntryTaskError.missing(NSLocalizedString("HEALTHKIT_ERROR_SAVE_DATA.message", comment: "Please enter correct value and then save."))
		}

		guard let segementedView = entryTaskView.entryView(forIdentifier: SegmentedEntryView.reuseIdentifier) as? SegmentedEntryView else {
			throw GeneralizedEntryTaskError.invalid("Invalid Context")
		}

		guard let value = Double(valueString) else {
			throw GeneralizedEntryTaskError.invalid("Value of invalid type")
		}

		let date = unitView.date
		let selectedIndex = segementedView.segementedControl.selectedSegmentIndex
		var mealTime: CHBloodGlucoseMealTime
		switch selectedIndex {
		case 0:
			mealTime = .fasting
		case 1:
			mealTime = .preprandial
		case 2:
			mealTime = .postprandial
		default:
			mealTime = .undefined
		}

		let sample = HKDiscreteQuantitySample(bloodGlucose: value, startDate: date, mealTime: mealTime)
		return sample
	}

	func createBodyMassSample() throws -> HKSample {
		guard let unitView = entryTaskView.entryView(forIdentifier: TimeValueEntryView.reuseIdentifier) as? TimeValueEntryView, let valueString = unitView.value, !valueString.isEmpty else {
			throw GeneralizedEntryTaskError.missing(NSLocalizedString("HEALTHKIT_ERROR_SAVE_DATA.message", comment: "Please enter correct value and then save."))
		}

		guard let value = Double(valueString) else {
			throw GeneralizedEntryTaskError.invalid("Value of invalid type")
		}

		let quantity = HKQuantity(unit: HealthKitDataType.bodyMass.unit, doubleValue: value)
		var metadata: [String: Any] = [:]
		metadata[HKMetadataKeyTimeZone] = TimeZone.current.identifier
		metadata[HKMetadataKeyWasUserEntered] = true
		metadata[CHMetadataKeyUpdatedDate] = Date()
		let quantityType = HKQuantityType.quantityType(forIdentifier: .bodyMass)
		let date = unitView.date
		let sample = HKDiscreteQuantitySample(type: quantityType!, quantity: quantity, start: date, end: date, device: HKDevice.local(), metadata: metadata)
		return sample
	}

	func createBloodPressureSample() throws -> HKSample {
		guard let view = entryTaskView.entryView(forIdentifier: MultiValueEntryView.reuseIdentifier) as? MultiValueEntryView, let lValueString = view.leadingValue, !lValueString.isEmpty, let tValueString = view.trailingValue, !tValueString.isEmpty else {
			throw GeneralizedEntryTaskError.missing(NSLocalizedString("HEALTHKIT_ERROR_SAVE_DATA.message", comment: "Please enter correct value and then save."))
		}

		guard let systolic = Double(lValueString), let diastolic = Double(tValueString) else {
			throw GeneralizedEntryTaskError.invalid("Value of invalid type")
		}

		let startDate = Date()
		let endDate = startDate
		let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!
		let systolicQuantity = HKQuantity(unit: HKUnit.millimeterOfMercury(), doubleValue: systolic)
		let systolicSample = HKDiscreteQuantitySample(type: systolicType, quantity: systolicQuantity, start: startDate, end: endDate)
		let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!
		let diastolicQuantity = HKQuantity(unit: HKUnit.millimeterOfMercury(), doubleValue: diastolic)
		let diastolicSample = HKDiscreteQuantitySample(type: diastolicType, quantity: diastolicQuantity, start: startDate, end: endDate)
		let bloodPressureCorrelationType = HKCorrelationType.correlationType(forIdentifier: .bloodPressure)!
		let bloodPressureCorrelation = Set<HKSample>(arrayLiteral: systolicSample, diastolicSample)
		let bloodPressureSample = HKCorrelation(type: bloodPressureCorrelationType, start: startDate, end: endDate, objects: bloodPressureCorrelation)

		var metadata: [String: Any] = [:]
		metadata[HKMetadataKeyTimeZone] = TimeZone.current.identifier
		metadata[HKMetadataKeyWasUserEntered] = true
		metadata[CHMetadataKeyUpdatedDate] = Date()
		return bloodPressureSample
	}

	private func showAlert(title: String?, message: String?, showSettings: Bool) {
		let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .cancel) { _ in
		}
		controller.addAction(cancelAction)
		if showSettings {
			let settingsAction = UIAlertAction(title: NSLocalizedString("SETTINGS", comment: "Settings"), style: .default) { _ in
				if let url = URL(string: UIApplication.openSettingsURLString) {
					UIApplication.shared.open(url, options: [:], completionHandler: nil)
				}
			}
			controller.addAction(settingsAction)
		}
		show(controller, sender: self)
	}
}

extension GeneralizedLogTaskDetailViewController: EntryTaskSectionHeaderViewDelegate {
	func entryTaskSectionHeaderViewDidSelectButton(_ view: EntryTaskSectionHeaderView) {
		cancelAction?()
	}
}

extension GeneralizedLogTaskDetailViewController: EntryTaskSectionFooterViewDelegate {
	func entryTaskSectionFooterViewDidSelectSave(_ view: EntryTaskSectionFooterView) {
		do {
			let sample = try createHealthKitSample()
			healthKitSampleHandler?(sample)
		} catch {
			let title = NSLocalizedString("HEALTHKIT_ERROR_SAVE_DATA", comment: "Error saving data!")
			var message: String?
			var showSettings = false
			switch error {
			case GeneralizedEntryTaskError.missing(let errorMessage):
				message = errorMessage
			default:
				message = error.localizedDescription
				showSettings = true
			}
			showAlert(title: title, message: message, showSettings: showSettings)
		}
	}

	func entryTaskSectionFooterViewDidSelectDelete(_ view: EntryTaskSectionFooterView) {
		deleteAction?()
	}
}

extension GeneralizedLogTaskDetailViewController: SegmentedEntryViewDelegate {
	func segmentedEntryView(_ view: SegmentedEntryView, didSelectItem index: Int) {}
}
