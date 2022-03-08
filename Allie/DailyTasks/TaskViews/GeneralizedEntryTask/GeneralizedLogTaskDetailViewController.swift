//
//  GeneralizedLogTaskDetailViewController.swift
//  Allie
//
//  Created by Waqar Malik on 7/5/21.
//

import CareKitStore
import CareModel
import Combine
import HealthKit
import JGProgressHUD
import UIKit

enum GeneralizedEntryTaskError: Error {
	case missing(String)
	case invalid(String)
}

// swiftlint:disable type_body_length
class GeneralizedLogTaskDetailViewController: UIViewController {
	var healthKitSampleHandler: AllieHealthKitSampleHandler?
	var outcomeValueHandler: AllieOutcomeValueHandler?

	var cancelAction: AllieActionHandler?
	var deleteAction: AllieActionHandler?

	let entryTaskView: GeneralizedLogTaskDetailView = {
		let view = GeneralizedLogTaskDetailView()
		return view
	}()

	lazy var hud: JGProgressHUD = {
		let hud = JGProgressHUD(style: .dark)
		hud.textLabel.text = NSLocalizedString("SAVING_DOTS", comment: "Saving...")
		return hud
	}()

	var outcome: CHOutcome?
	var outcomeValues: [OCKOutcomeValue] = []
	var outcomeIndex: Int?
	var anyTask: OCKAnyTask?
	var queryDate = Date()
	var task: OCKTask? {
		anyTask as? OCKTask
	}

	var existingSample: HKSample?

	var healthKitTask: OCKHealthKitTask? {
		anyTask as? OCKHealthKitTask
	}

	let headerView: TaskHeaderView = {
		let view = TaskHeaderView(frame: .zero)
		view.button.setImage(UIImage(systemName: "multiply"), for: .normal)
		view.button.backgroundColor = .allieLighterGray
		view.textLabel.text = "Insulin"
		view.detailTextLabel.text = "Instructions"
		view.imageView.image = UIImage(named: "icon-insulin")
		view.heightAnchor.constraint(equalToConstant: TaskHeaderView.height).isActive = true
		return view
	}()

	let footerView: EntryTaskSectionFooterView = {
		let view = EntryTaskSectionFooterView(frame: .zero)
		view.saveButton.setTitle(NSLocalizedString("SAVE", comment: "Save"), for: .normal)
		view.heightAnchor.constraint(equalToConstant: EntryTaskSectionFooterView.height).isActive = true
		return view
	}()

	private(set) var identifiers: [String] = []

	private(set) lazy var numberFormatter = NumberFormatter.valueFormatter
	private var cancellables: Set<AnyCancellable> = []

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
		if let healthKitTask = healthKitTask {
			configureView(healthKitTask: healthKitTask)
		} else {
			configureView(task: task)
		}

		registerSymptomPublisher()
		if let exstingValue = outcomeValues.first?.stringValue, task?.groupIdentifierType == .symptoms {
			selectedOutcome = exstingValue
		}
	}

	private func addView(identifier: String, at index: Int) {
		if identifier == EntrySegmentedView.reuseIdentifier {
			let cell = entryTaskView.dequeueCell(identifier: identifier, at: index) as? EntrySegmentedView
			configure(segementedEntryView: cell)
		} else if identifier == EntryTimePickerView.reuseIdentifier {
			let cell = entryTaskView.dequeueCell(identifier: identifier, at: index) as? EntryTimePickerView
			configure(timeValueEntryView: cell)
		} else if identifier == EntryTimePickerNoValueView.reuseIdentifier {
			let cell = entryTaskView.dequeueCell(identifier: identifier, at: index) as? EntryTimePickerNoValueView
			configure(timeNoValueEntryView: cell)
		} else if identifier == EntryMultiValueEntryView.reuseIdentifier {
			let cell = entryTaskView.dequeueCell(identifier: identifier, at: index) as? EntryMultiValueEntryView
			if healthKitTask?.healthKitLinkage.quantityIdentifier == .bloodPressureDiastolic || healthKitTask?.healthKitLinkage.quantityIdentifier == .bloodPressureSystolic {
				configure(bloodPressureEntryView: cell)
			} else {
				configure(multiValueEntryView: cell)
			}
		} else if identifier == EntryListPickerView.reuseIdentifier {
			let cell = entryTaskView.dequeueCell(identifier: identifier, at: index) as? EntryListPickerView
			configure(listPickerView: cell)
		}
	}

	private func configure(segementedEntryView cell: EntrySegmentedView?) {
		guard let cell = cell else {
			return
		}
		let outcomeValue = outcomeValues.first
		var titles: [String] = []
		if healthKitTask?.healthKitLinkage.quantityIdentifier == .insulinDelivery {
			let reasons = [HKInsulinDeliveryReason.bolus, HKInsulinDeliveryReason.basal]
			titles = reasons.compactMap { reason in
				reason.title
			}
			cell.configure(titles: titles)
			var selectedIndex = 0
			if let reason = outcomeValue?.insulinDeliveryReason, let index = reasons.firstIndex(of: reason) {
				selectedIndex = index
			}
			cell.segementedControl.selectedSegmentIndex = selectedIndex
		} else if healthKitTask?.healthKitLinkage.quantityIdentifier == .bloodGlucose {
			let mealTimes = [CHBloodGlucoseMealTime.fasting, CHBloodGlucoseMealTime.preprandial, CHBloodGlucoseMealTime.postprandial]
			titles = mealTimes.map { mealTime in
				mealTime.title
			}
			cell.configure(titles: titles)
			if let mealTime = outcomeValue?.bloodGlucoseMealTime, let index = mealTimes.firstIndex(of: mealTime) {
				cell.selectedIndex = index
			}
		} else if let titles = task?.groupIdentifierType?.segmentTitles {
			cell.configure(titles: titles)
			if let value = outcomeValue?.kind, let severityType = CHOutcomeValueSeverityType(rawValue: value), let index = titles.firstIndex(of: severityType.title) {
				cell.selectedIndex = index
			}
		}
		cell.delegate = self
	}

	private func configure(timeValueEntryView cell: EntryTimePickerView?) {
		guard let cell = cell else {
			return
		}
		cell.translatesAutoresizingMaskIntoConstraints = false

		let outcomeValue = outcomeValues.first
		let unit = healthKitTask?.healthKitLinkage.unit
		let elements = healthKitTask?.schedule.elements
		let targetValue = elements?.first?.targetValues.first
		let placeholder = targetValue?.integerValue ?? 100
		var value: String?
		if let intValue = outcomeValue?.integerValue {
			value = numberFormatter.string(from: NSNumber(value: intValue))
		} else if let doubleValue = outcomeValue?.doubleValue {
			value = numberFormatter.string(from: NSNumber(value: doubleValue))
		}
		let date = outcomeValue?.createdDate ?? queryDate.byUpdatingTimeToNow
		if healthKitTask?.healthKitLinkage.quantityIdentifier == .bloodGlucose || healthKitTask?.healthKitLinkage.quantityIdentifier == .bodyMass {
			cell.keyboardType = .numberPad
		}
		cell.canEditValue = outcomeValue?.wasUserEntered ?? true
		let placeHolderString = numberFormatter.string(from: NSNumber(value: placeholder)) ?? "\(placeholder)"
		cell.configure(placeHolder: placeHolderString, value: value, unitTitle: unit?.displayUnitSting ?? "", date: date, isActive: true)
	}

	private func configure(timeNoValueEntryView cell: EntryTimePickerNoValueView?) {
		guard let cell = cell else {
			return
		}
		cell.translatesAutoresizingMaskIntoConstraints = false

		let outcomeValue = outcomeValues.first
		let date = outcomeValue?.createdDate ?? queryDate.byUpdatingTimeToNow
		cell.configure(date: date, isActive: true)
	}

	private func configure(multiValueEntryView cell: EntryMultiValueEntryView?) {
		cell?.translatesAutoresizingMaskIntoConstraints = false
		cell?.heightAnchor.constraint(equalToConstant: EntryMultiValueEntryView.height).isActive = true
		guard let targetValues = healthKitTask?.schedule.elements.first?.targetValues else {
			return
		}
		cell?.leadingEntryView.isHidden = true
		cell?.trailingEntryView.isHidden = true
		for (index, value) in targetValues.enumerated() {
			if index == 0 {
				cell?.leadingEntryView.isHidden = false
				cell?.leadingEntryView.textField.placeholder = numberFormatter.string(from: NSNumber(value: value.integerValue ?? 0))
				cell?.leadingEntryView.textLabel.text = value.units
				cell?.leadingEntryView.textField.becomeFirstResponder()
			} else if index == 1 {
				cell?.trailingEntryView.isHidden = false
				cell?.trailingEntryView.textField.placeholder = numberFormatter.string(from: NSNumber(value: value.integerValue ?? 0))
				cell?.trailingEntryView.textLabel.text = value.units
			} else {
				break
			}
		}
	}

	private func configure(bloodPressureEntryView cell: EntryMultiValueEntryView?) {
		cell?.translatesAutoresizingMaskIntoConstraints = false
		cell?.heightAnchor.constraint(equalToConstant: EntryMultiValueEntryView.height).isActive = true
		guard let targetValues = healthKitTask?.schedule.elements.first?.targetValues else {
			return
		}
		cell?.leadingEntryView.isHidden = false
		cell?.trailingEntryView.isHidden = false

		if targetValues[0].kind == "systolic" {
			cell?.leadingEntryView.textField.placeholder = numberFormatter.string(from: NSNumber(value: targetValues[0].integerValue ?? 0))
			cell?.leadingEntryView.textLabel.text = targetValues[0].units
			cell?.leadingEntryView.textField.becomeFirstResponder()
			cell?.trailingEntryView.textField.placeholder = numberFormatter.string(from: NSNumber(value: targetValues[1].integerValue ?? 0))
			cell?.trailingEntryView.textLabel.text = targetValues[1].units
		} else {
			cell?.leadingEntryView.textField.placeholder = numberFormatter.string(from: NSNumber(value: targetValues[1].integerValue ?? 0))
			cell?.leadingEntryView.textLabel.text = targetValues[1].units
			cell?.leadingEntryView.textField.becomeFirstResponder()
			cell?.trailingEntryView.textField.placeholder = numberFormatter.string(from: NSNumber(value: targetValues[0].integerValue ?? 0))
			cell?.trailingEntryView.textLabel.text = targetValues[0].units
		}

		if let firstOutcomeValue = outcomeValues.first, let secondOutcomeValue = outcomeValues.last, let firstValue = firstOutcomeValue.integerValue, let secondValue = secondOutcomeValue.integerValue {
			if firstOutcomeValue.quantityIdentifier == HKQuantityTypeIdentifier.bloodPressureSystolic.rawValue {
				cell?.leadingEntryView.textField.text = numberFormatter.string(from: NSNumber(value: firstValue))
				cell?.trailingEntryView.textField.text = numberFormatter.string(from: NSNumber(value: secondValue))
			} else {
				cell?.leadingEntryView.textField.text = numberFormatter.string(from: NSNumber(value: secondValue))
				cell?.trailingEntryView.textField.text = numberFormatter.string(from: NSNumber(value: firstValue))
			}
		}
	}

	@Published private var selectedOutcome: String? {
		didSet {
			let listPickerView = entryTaskView.entryView(forIdentifier: EntryListPickerView.reuseIdentifier) as? EntryListPickerView
			listPickerView?.selectedValue = selectedOutcome
		}
	}

	private func configure(listPickerView cell: EntryListPickerView?) {
		let outcomeValue = outcomeValues.first

		cell?.delegate = self
		cell?.selectedValue = selectedOutcome ?? outcomeValue?.stringValue ?? NSLocalizedString("SELECT", comment: "Select")
	}

	private func registerSymptomPublisher() {
		guard let identifier = task?.groupIdentifierType, identifier == .symptoms else {
			return
		}
		$selectedOutcome.map { value -> Bool in
			guard let value = value else {
				return false
			}
			return !value.isEmpty
		}
		.map { [weak self] enabled -> Bool in
			guard let isEmpty = self?.outcomeValues.isEmpty, isEmpty else {
				return true
			}
			return enabled
		}
		.assign(to: \.isSaveButtonEnabled, on: footerView)
		.store(in: &cancellables)
	}

	private func configureView(task: OCKTask?) {
		headerView.textLabel.text = task?.title
		headerView.detailTextLabel.text = task?.instructions
		headerView.imageView.image = task?.groupIdentifierType?.icon

		guard let identifierType = task?.groupIdentifierType, let identifiers = identifierType.taskViews else {
			return
		}
		self.identifiers = identifiers
		for (index, identifier) in self.identifiers.enumerated() {
			addView(identifier: identifier, at: index)
		}
		footerView.deleteButton.isHidden = outcomeValues.isEmpty
	}

	private func configureView(healthKitTask task: OCKHealthKitTask?) {
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
		footerView.deleteButton.isHidden = outcomeValues.isEmpty
	}

	func createHealthKitSample() throws -> HKSample {
		guard let quantityIdentifier = healthKitTask?.healthKitLinkage.quantityIdentifier else {
			throw GeneralizedEntryTaskError.missing(NSLocalizedString("INVALID_QUANTITY_IDENTIFIER", comment: "Quantity Identifier"))
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
			throw GeneralizedEntryTaskError.invalid(NSLocalizedString("INVALID_QUANTITY_IDENTIFIER", comment: "Quantity Identifier"))
		}
		return sample
	}

	func createInsulinSample() throws -> HKSample {
		guard let unitView = entryTaskView.entryView(forIdentifier: EntryTimePickerView.reuseIdentifier) as? EntryTimePickerView, let valueString = unitView.value, !valueString.isEmpty else {
			throw GeneralizedEntryTaskError.missing(NSLocalizedString("HEALTHKIT_ERROR_SAVE_DATA.message", comment: "Please enter correct value and then save."))
		}

		guard let segementedView = entryTaskView.entryView(forIdentifier: EntrySegmentedView.reuseIdentifier) as? EntrySegmentedView else {
			throw GeneralizedEntryTaskError.invalid(NSLocalizedString("INVALID_CONTEXT", comment: "Invalid Context"))
		}

		guard let value = numberFormatter.number(from: valueString)?.doubleValue else {
			throw GeneralizedEntryTaskError.invalid(NSLocalizedString("VALUE_NOT_VALID", comment: "Value is not a valid."))
		}

		let selectedIndex = segementedView.segementedControl.selectedSegmentIndex
		let reason: HKInsulinDeliveryReason = selectedIndex == 0 ? .bolus : .basal
		let valueRange = reason.valueRange
		guard value > valueRange.lowerBound, value <= valueRange.upperBound else {
			let message = NSLocalizedString("VALUE_RANGE_INVALID_VALUES_GREATER", comment: "Value must be greater than") +
				" \(Int(valueRange.lowerBound)) " +
				NSLocalizedString("VALUE_RANGE_INVALID_VALUES_LESS", comment: "and less than or equal to") +
				" \(Int(valueRange.upperBound))."

			throw GeneralizedEntryTaskError.invalid(message)
		}

		let date = unitView.date
		let sample = HKDiscreteQuantitySample(insulinUnits: value, startDate: date, reason: reason, metadata: existingSample?.metadata)
		return sample
	}

	func createBloodGlucoseSample() throws -> HKSample {
		guard let unitView = entryTaskView.entryView(forIdentifier: EntryTimePickerView.reuseIdentifier) as? EntryTimePickerView, let valueString = unitView.value, !valueString.isEmpty else {
			throw GeneralizedEntryTaskError.missing(NSLocalizedString("HEALTHKIT_ERROR_SAVE_DATA.message", comment: "Please enter correct value and then save."))
		}

		guard let segementedView = entryTaskView.entryView(forIdentifier: EntrySegmentedView.reuseIdentifier) as? EntrySegmentedView else {
			throw GeneralizedEntryTaskError.invalid(NSLocalizedString("INVALID_CONTEXT", comment: "Invalid Context"))
		}

		guard let value = numberFormatter.number(from: valueString)?.intValue else {
			throw GeneralizedEntryTaskError.invalid(NSLocalizedString("VALUE_RANGE_INVALID", comment: "Value must be greater than 0 and less than 1000"))
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
			mealTime = .unknown
		}
		let valueRange = mealTime.valueRange
		guard value > valueRange.lowerBound, value <= valueRange.upperBound else {
			throw GeneralizedEntryTaskError.invalid(NSLocalizedString("VALUE_RANGE_INVALID", comment: "Value must be greater than \(valueRange.lowerBound) and less than or equal to \(valueRange.upperBound)"))
		}

		let sample = HKDiscreteQuantitySample(bloodGlucose: Double(value), startDate: date, mealTime: mealTime, metadata: existingSample?.metadata)
		return sample
	}

	func createBodyMassSample() throws -> HKSample {
		guard let unitView = entryTaskView.entryView(forIdentifier: EntryTimePickerView.reuseIdentifier) as? EntryTimePickerView, let valueString = unitView.value, !valueString.isEmpty else {
			throw GeneralizedEntryTaskError.missing(NSLocalizedString("HEALTHKIT_ERROR_SAVE_DATA.message", comment: "Please enter correct value and then save."))
		}

		guard let value = numberFormatter.number(from: valueString)?.intValue, value > 0, value < 1000 else {
			throw GeneralizedEntryTaskError.invalid(NSLocalizedString("VALUE_RANGE_INVALID", comment: "Value must be greater than 0 and less than 1000"))
		}

		let quantity = HKQuantity(unit: HealthKitDataType.bodyMass.unit, doubleValue: Double(value))
		var metadata: [String: Any] = existingSample?.metadata ?? [:]
		metadata[HKMetadataKeyTimeZone] = TimeZone.current.identifier
		metadata[HKMetadataKeyWasUserEntered] = true
		metadata[CHMetadataKeyUpdatedDate] = Date()
		let quantityType = HKQuantityType.quantityType(forIdentifier: .bodyMass)
		let date = unitView.date
		let sample = HKDiscreteQuantitySample(type: quantityType!, quantity: quantity, start: date, end: date, device: HKDevice.local(), metadata: metadata)
		return sample
	}

	func createBloodPressureSample() throws -> HKSample {
		guard let view = entryTaskView.entryView(forIdentifier: EntryMultiValueEntryView.reuseIdentifier) as? EntryMultiValueEntryView, let lValueString = view.leadingValue, !lValueString.isEmpty, let tValueString = view.trailingValue, !tValueString.isEmpty else {
			throw GeneralizedEntryTaskError.missing(NSLocalizedString("HEALTHKIT_ERROR_SAVE_DATA.message", comment: "Please enter correct value and then save."))
		}

		guard let systolic = numberFormatter.number(from: lValueString)?.intValue, let diastolic = numberFormatter.number(from: tValueString)?.intValue else {
			throw GeneralizedEntryTaskError.invalid(NSLocalizedString("INVALID_VALUE_TYPE", comment: "Value of invalid type"))
		}

		guard systolic >= 50, systolic <= 250 else {
			throw GeneralizedEntryTaskError.invalid(NSLocalizedString("BLOODPRESSURE_SYSTOLIC_VALUE_RANGE_INVALID", comment: "Systolic value must be greater than 50 and less than 250"))
		}
		guard diastolic >= 25, diastolic <= 200 else {
			throw GeneralizedEntryTaskError.invalid(NSLocalizedString("BLOODPRESSURE_DIASTOLIC_VALUE_RANGE_INVALID", comment: "Diastolic value must be greater than 25 and less than 200"))
		}

		guard let unitView = entryTaskView.entryView(forIdentifier: EntryTimePickerNoValueView.reuseIdentifier) as? EntryTimePickerNoValueView else {
			throw GeneralizedEntryTaskError.missing(NSLocalizedString("HEALTHKIT_ERROR_SAVE_DATA.message", comment: "Internal Error: wrong view type."))
		}

		let startDate = unitView.date
		let endDate = startDate
		let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!
		let systolicQuantity = HKQuantity(unit: HKUnit.millimeterOfMercury(), doubleValue: Double(systolic))
		let systolicSample = HKQuantitySample(type: systolicType, quantity: systolicQuantity, start: startDate, end: endDate)
		let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!
		let diastolicQuantity = HKQuantity(unit: HKUnit.millimeterOfMercury(), doubleValue: Double(diastolic))
		let diastolicSample = HKQuantitySample(type: diastolicType, quantity: diastolicQuantity, start: startDate, end: endDate)
		let bloodPressureCorrelationType = HKCorrelationType.correlationType(forIdentifier: .bloodPressure)!
		let bloodPressureCorrelation = Set<HKSample>(arrayLiteral: systolicSample, diastolicSample)

		var metadata: [String: Any] = existingSample?.metadata ?? [:]
		metadata[HKMetadataKeyTimeZone] = TimeZone.current.identifier
		metadata[HKMetadataKeyWasUserEntered] = true
		metadata[CHMetadataKeyUpdatedDate] = Date()

		let bloodPressureSample = HKCorrelation(type: bloodPressureCorrelationType, start: startDate, end: endDate, objects: bloodPressureCorrelation, metadata: metadata)
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

	private func showSymptolSelectionAlert() {
		guard let element = task?.schedule.elements.first else {
			return
		}
		let titles = element.targetValues.compactMap { value in
			value.stringValue
		}
		guard !titles.isEmpty else {
			return
		}
		let title = NSLocalizedString("SELECT_A_SYMPTOM", comment: "Select a Symptom")
		let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
		for title in titles {
			let alertAction = UIAlertAction(title: title, style: .default) { action in
				self.selectedOutcome = action.title
			}
			actionSheet.addAction(alertAction)
		}

		let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .cancel) { _ in
		}
		actionSheet.addAction(cancelAction)

		show(actionSheet, sender: self)
	}

	private func createOutcomeValue() throws -> OCKOutcomeValue {
		guard let taskType = task?.groupIdentifierType, taskType == .symptoms else {
			throw GeneralizedEntryTaskError.invalid(NSLocalizedString("TASK_NOT_SUPPORTED", comment: "Task not supported"))
		}
		guard let value = selectedOutcome, !value.isEmpty else {
			throw GeneralizedEntryTaskError.invalid(NSLocalizedString("VALUE_MISSING", comment: "Value missing"))
		}

		guard let segementedView = entryTaskView.entryView(forIdentifier: EntrySegmentedView.reuseIdentifier) as? EntrySegmentedView else {
			throw GeneralizedEntryTaskError.invalid(NSLocalizedString("INVALID_CONTEXT", comment: "Invalid Context"))
		}

		guard let selectedTitle = segementedView.selectedTitle, let severityType = CHOutcomeValueSeverityType(title: selectedTitle) else {
			throw GeneralizedEntryTaskError.missing(NSLocalizedString("SEVERITY_MISSING", comment: "Severity not selected"))
		}

		var newOutcomeValue = OCKOutcomeValue(value, units: nil)
		newOutcomeValue.kind = severityType.rawValue
		newOutcomeValue.wasUserEntered = true
		newOutcomeValue.createdDate = outcomeValues.first?.createdDate ?? queryDate.byUpdatingTimeToNow
		return newOutcomeValue
	}

	private func saveHealthKit() {
		hud.show(in: tabBarController?.view ?? view)
		do {
			let sample = try createHealthKitSample()
			healthKitSampleHandler?(sample)
			hud.dismiss(animated: true)
		} catch {
			hud.dismiss(animated: true)
			let title = NSLocalizedString("HEALTHKIT_ERROR_SAVE_DATA", comment: "Error saving data!")
			var message: String?
			var showSettings = false
			switch error {
			case GeneralizedEntryTaskError.missing(let errorMessage):
				message = errorMessage
			case GeneralizedEntryTaskError.invalid(let errorMessage):
				message = errorMessage
			default:
				message = error.localizedDescription
				showSettings = true
			}
			showAlert(title: title, message: message, showSettings: showSettings)
		}
	}

	func saveOutcomeValue() {
		hud.show(in: tabBarController?.view ?? view)
		do {
			let outcomeValue = try createOutcomeValue()
			outcomeValueHandler?(outcomeValue)
			hud.dismiss(animated: true)
		} catch {
			hud.dismiss(animated: true)
			let title = NSLocalizedString("ERROR_SAVING_OUTCOME", comment: "Error saving outcome!")
			var message: String?
			var showSettings = false
			switch error {
			case GeneralizedEntryTaskError.missing(let errorMessage):
				message = errorMessage
			case GeneralizedEntryTaskError.invalid(let errorMessage):
				message = errorMessage
			default:
				message = error.localizedDescription
				showSettings = true
			}
			showAlert(title: title, message: message, showSettings: showSettings)
		}
	}
}

extension GeneralizedLogTaskDetailViewController: TaskHeaderViewDelegate {
	func taskHeaderViewDidSelectButton(_ view: TaskHeaderView) {
		cancelAction?()
	}
}

extension GeneralizedLogTaskDetailViewController: EntryTaskSectionFooterViewDelegate {
	func entryTaskSectionFooterViewDidSelectSave(_ view: EntryTaskSectionFooterView) {
		if healthKitTask != nil {
			saveHealthKit()
		} else if task != nil {
			saveOutcomeValue()
		}
	}

	func entryTaskSectionFooterViewDidSelectDelete(_ view: EntryTaskSectionFooterView) {
		deleteAction?()
	}
}

extension GeneralizedLogTaskDetailViewController: EntrySegmentedViewDelegate {
	func segmentedEntryView(_ view: EntrySegmentedView, didSelectItem index: Int) {}
}

extension GeneralizedLogTaskDetailViewController: EntryListPickerViewDelegate {
	func entryListPickerViewDidSelectShow(_ view: EntryListPickerView) {
		showSymptolSelectionAlert()
	}
}
