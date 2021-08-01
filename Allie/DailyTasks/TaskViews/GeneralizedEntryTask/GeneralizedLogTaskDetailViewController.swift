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
	var saveAction: AllieActionHandler?
	var cancelAction: AllieActionHandler?
	var deleteAction: AllieActionHandler?

	let entryTaskView: GeneralizedLogTaskDetailView = {
		let view = GeneralizedLogTaskDetailView()
		return view
	}()

	var outcome: OCKAnyOutcome?

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

	var identifiers: [String] = []
	var task: OCKHealthKitTask?

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
			titles = ["Fasting", "Before Meal", "After Meal"]
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
		let outcomeValue = outcome?.values.first
		var value: String?
		if let intValue = outcomeValue?.integerValue {
			value = "\(intValue)"
		} else if let doubleValue = outcomeValue?.doubleValue {
			value = "\(Int(doubleValue))"
		}
		let date = outcomeValue?.createdDate
		cell.configure(placeHolder: "\(placeholder)", value: value, unitTitle: unit?.unitString ?? "", date: date, isActive: true)
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
		footerView.deleteButton.isHidden = outcome == nil
		footerView.saveButton.isHidden = outcome != nil
	}

	func saveToHealthKit(completion: @escaping AllieResultCompletion<Bool>) {
		guard let quantityIdentifier = task?.healthKitLinkage.quantityIdentifier else {
			completion(.failure(GeneralizedEntryTaskError.missing("Quantity Identifier")))
			return
		}

		if quantityIdentifier == .insulinDelivery {
			saveInsulin(completion: completion)
		} else if quantityIdentifier == .bloodGlucose {
			saveBloodGlucose(completion: completion)
		} else if quantityIdentifier == .bodyMass {
			saveBodyMass(completion: completion)
		} else if quantityIdentifier == .bloodPressureDiastolic || quantityIdentifier == .bloodPressureSystolic {
			saveBloodPressure(completion: completion)
		} else {
			completion(.failure(GeneralizedEntryTaskError.invalid("Quantity Identifier")))
		}
	}

	func saveInsulin(completion: @escaping AllieResultCompletion<Bool>) {
		guard let unitView = entryTaskView.entryView(forIdentifier: TimeValueEntryView.reuseIdentifier) as? TimeValueEntryView, let valueString = unitView.value, !valueString.isEmpty else {
			completion(.failure(GeneralizedEntryTaskError.missing("Missing Value")))
			return
		}
		guard let segementedView = entryTaskView.entryView(forIdentifier: SegmentedEntryView.reuseIdentifier) as? SegmentedEntryView else {
			completion(.failure(GeneralizedEntryTaskError.invalid("Invalid Context")))
			return
		}

		guard let value = Double(valueString) else {
			completion(.failure(GeneralizedEntryTaskError.invalid("Value of invalid type")))
			return
		}

		let date = unitView.date
		let selectedIndex = segementedView.segementedControl.selectedSegmentIndex
		let reason: HKInsulinDeliveryReason = selectedIndex == 0 ? .bolus : .basal
		let sample = HKDiscreteQuantitySample(insulinUnits: value, startDate: date, reason: reason)
		HKHealthStore().save(sample) { result, error in
			if let error = error {
				ALog.error("Unable to save insulin values", error: error)
				completion(.failure(error))
			} else {
				completion(.success(result))
			}
		}
	}

	func saveBloodGlucose(completion: @escaping AllieResultCompletion<Bool>) {
		guard let unitView = entryTaskView.entryView(forIdentifier: TimeValueEntryView.reuseIdentifier) as? TimeValueEntryView, let valueString = unitView.value, !valueString.isEmpty else {
			completion(.failure(GeneralizedEntryTaskError.missing("Missing Value")))
			return
		}
		guard let segementedView = entryTaskView.entryView(forIdentifier: SegmentedEntryView.reuseIdentifier) as? SegmentedEntryView else {
			completion(.failure(GeneralizedEntryTaskError.invalid("Invalid Context")))
			return
		}

		guard let value = Double(valueString) else {
			completion(.failure(GeneralizedEntryTaskError.invalid("Value of invalid type")))
			return
		}

		let date = unitView.date
		let selectedIndex = segementedView.segementedControl.selectedSegmentIndex
		var mealTime: HKBloodGlucoseMealTime?
		switch selectedIndex {
		case 1:
			mealTime = .preprandial
		case 2:
			mealTime = .postprandial
		default:
			mealTime = nil
		}
		let sample = HKDiscreteQuantitySample(bloodGlucose: value, startDate: date, mealTime: mealTime)
		HKHealthStore().save(sample) { result, error in
			if let error = error {
				ALog.error("Unable to save blood glucose values", error: error)
				completion(.failure(error))
			} else {
				completion(.success(result))
			}
		}
	}

	func saveBodyMass(completion: @escaping AllieResultCompletion<Bool>) {
		guard let unitView = entryTaskView.entryView(forIdentifier: TimeValueEntryView.reuseIdentifier) as? TimeValueEntryView, let valueString = unitView.value, !valueString.isEmpty else {
			completion(.failure(GeneralizedEntryTaskError.missing("Missing Value")))
			return
		}
		guard let value = Double(valueString) else {
			completion(.failure(GeneralizedEntryTaskError.invalid("Value of invalid type")))
			return
		}

		let quantity = HKQuantity(unit: HealthKitDataType.bodyMass.unit, doubleValue: value)
		var metadata: [String: Any] = [:]
		metadata[HKMetadataKeyTimeZone] = TimeZone.current.identifier
		metadata[HKMetadataKeyWasUserEntered] = true
		let quantityType = HKQuantityType.quantityType(forIdentifier: .bodyMass)
		let date = unitView.date
		let sample = HKDiscreteQuantitySample(type: quantityType!, quantity: quantity, start: date, end: date, device: HKDevice.local(), metadata: metadata)
		HKHealthStore().save(sample) { result, error in
			if let error = error {
				ALog.error("Unable to save blood glucose values", error: error)
				completion(.failure(error))
			} else {
				completion(.success(result))
			}
		}
	}

	func saveBloodPressure(completion: @escaping AllieResultCompletion<Bool>) {
		guard let view = entryTaskView.entryView(forIdentifier: MultiValueEntryView.reuseIdentifier) as? MultiValueEntryView, let lValueString = view.leadingValue, !lValueString.isEmpty, let tValueString = view.trailingValue, !tValueString.isEmpty else {
			completion(.failure(GeneralizedEntryTaskError.missing("Missing Value")))
			return
		}

		guard let systolic = Double(lValueString), let diastolic = Double(tValueString) else {
			completion(.failure(GeneralizedEntryTaskError.invalid("Value of invalid type")))
			return
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
		HKHealthStore().save(bloodPressureSample) { result, error in
			if let error = error {
				ALog.error("Unable to save blood pressure values", error: error)
				completion(.failure(error))
			} else {
				completion(.success(result))
			}
		}
	}

	private func showErrorAlert(title: String?, error: Error) {
		let controller = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .cancel) { _ in
		}
		let settingsAction = UIAlertAction(title: NSLocalizedString("SETTINGS", comment: "Settings"), style: .default) { _ in
			if let url = URL(string: UIApplication.openSettingsURLString) {
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
			}
		}
		controller.addAction(cancelAction)
		controller.addAction(settingsAction)
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
		saveToHealthKit { [weak self] result in
			DispatchQueue.main.async {
				switch result {
				case .failure(let error):
					let title = NSLocalizedString("HEALTHKIT_ERROR_SAVE_DATA", comment: "Error saving data!")
					self?.showErrorAlert(title: title, error: error)
				case .success(let success):
					ALog.info("Sample saved \(success)")
					self?.saveAction?()
				}
			}
		}
	}

	func entryTaskSectionFooterViewDidSelectDelete(_ view: EntryTaskSectionFooterView) {
		deleteAction?()
	}
}

extension GeneralizedLogTaskDetailViewController: SegmentedEntryViewDelegate {
	func segmentedEntryView(_ view: SegmentedEntryView, didSelectItem index: Int) {}
}
