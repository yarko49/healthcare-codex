//
//  GeneralizedEntryTaskViewController.swift
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

protocol GeneralizedEntryTaskViewControllerDelegate: AnyObject {
	func generalizedEntryTaskViewControllerDidCancel(_ viewController: GeneralizedEntryTaskViewController)
	func generalizedEntryTaskViewControllerDidSave(_ viewController: GeneralizedEntryTaskViewController)
}

class GeneralizedEntryTaskViewController: UIViewController {
	let entryTaskView: GeneralizedEntryTaskView = {
		let view = GeneralizedEntryTaskView()
		return view
	}()

	weak var delegate: GeneralizedEntryTaskViewControllerDelegate?

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
		view.button.setTitle(NSLocalizedString("SAVE", comment: "Save"), for: .normal)
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
		let value = targetValue?.integerValue ?? 100
		cell.configure(placeHolder: "\(value)", title: unit?.unitString ?? "", date: nil)
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
			cell?.trailingEntryView.textField.placeholder = "\(targetValues[1].integerValue ?? 0)"
			cell?.trailingEntryView.textLabel.text = targetValues[1].units
		} else {
			cell?.leadingEntryView.textField.placeholder = "\(targetValues[1].integerValue ?? 0)"
			cell?.leadingEntryView.textLabel.text = targetValues[1].units
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
		let systolicQuantity = HKQuantity(unit: HealthKitDataType.bloodPressure.unit, doubleValue: systolic)
		let systolicSample = HKQuantitySample(type: systolicType, quantity: systolicQuantity, start: startDate, end: endDate)
		let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!
		let diastolicQuantity = HKQuantity(unit: HealthKitDataType.bloodPressure.unit, doubleValue: diastolic)
		let diastolicSample = HKQuantitySample(type: diastolicType, quantity: diastolicQuantity, start: startDate, end: endDate)
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
}

extension GeneralizedEntryTaskViewController: EntryTaskSectionHeaderViewDelegate {
	func entryTaskSectionHeaderViewDidSelectButton(_ view: EntryTaskSectionHeaderView) {
		delegate?.generalizedEntryTaskViewControllerDidCancel(self)
	}
}

extension GeneralizedEntryTaskViewController: EntryTaskSectionFooterViewDelegate {
	func entryTaskSectionFooterViewDidSelectButton(_ view: EntryTaskSectionFooterView) {
		saveToHealthKit { result in
			switch result {
			case .failure(let error):
				ALog.error("Unable to save value", error: error)
			case .success(let success):
				ALog.info("Sample saved \(success)")
			}
		}

		delegate?.generalizedEntryTaskViewControllerDidSave(self)
	}
}

extension GeneralizedEntryTaskViewController: SegmentedEntryViewDelegate {
	func segmentedEntryView(_ view: SegmentedEntryView, didSelectItem index: Int) {}
}
