//
//  TodayInputVC.swift
//  alfred-ios
//

import Foundation
import HealthKitToFhir
import UIKit

enum InputType: String, Codable {
	case bloodPressure
	case weight
}

class PickerTapGesture: UITapGestureRecognizer {
	var picker: UIPickerView?
	var datePicker: UIDatePicker?
	var viewTF: PickerTF?
}

class TodayInputVC: BaseVC {
	// MARK: - Coordinator Actions

	var inputAction: ((Int?, Int?, String?, InputType) -> Void)?

	// MARK: - Properties

	var inputType: InputType = .weight
	var weightPicker = UIPickerView()
	var goalWeightPicker = UIPickerView()
	var bloodPressurePicker = UIPickerView()
	var lbsData: [[Int]] = [Array(25 ... 300), Array(0 ... 9)]
	var pressureData: [[Int]] = [Array(0 ... 200), Array(0 ... 200)]
	var weightPTF = PickerTF()
	var goalWeightPTF = PickerTF()
	var bloodPressurePTF = PickerTF()
	var datePTF = PickerTF()
	var timePTF = PickerTF()

	private let datePicker: UIDatePicker = {
		let calendar = Calendar(identifier: .gregorian)
		let components = NSDateComponents()
		components.year = 1970
		components.month = 1
		components.day = 1
		var startDate = Date()

		let defaultDate: NSDate = calendar.date(from: components as DateComponents)! as NSDate
		let picker = UIDatePicker()
		if #available(iOS 13.4, *) {
			picker.preferredDatePickerStyle = .wheels
		}
		picker.datePickerMode = .date
		picker.backgroundColor = UIColor.white
		picker.maximumDate = Date()
		picker.setDate(defaultDate as Date, animated: false)

		return picker
	}()

	private let timePicker: UIDatePicker = {
		let calendar = Calendar(identifier: .gregorian)
		let components = NSDateComponents()
		var startDate = Date()

		let defaultDate: NSDate = calendar.date(from: components as DateComponents)! as NSDate
		let picker = UIDatePicker()
		if #available(iOS 13.4, *) {
			picker.preferredDatePickerStyle = .wheels
		}
		picker.datePickerMode = .time
		picker.backgroundColor = UIColor.white
		picker.maximumDate = Date()
		picker.setDate(defaultDate as Date, animated: false)
		return picker
	}()

	// MARK: - IBOutlets

	@IBOutlet var sv: UIStackView!

	// MARK: - Setup

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func setupView() {
		super.setupView()

		setupDatePickerAndView(picker: datePicker, viewTF: datePTF, title: Str.date)
		setupDatePickerAndView(picker: timePicker, viewTF: timePTF, title: Str.time)
		datePicker.addTarget(self, action: #selector(datePickerDateChanged(_:)), for: .valueChanged)
		timePicker.addTarget(self, action: #selector(timePickerDateChanged(_:)), for: .valueChanged)
		datePTF.textfield.text = Str.defaultDate
		timePTF.textfield.text = Str.defaultTime
		datePTF.textfield.textColor = .black
		timePTF.textfield.textColor = .black

		switch inputType {
		case .bloodPressure:
			title = Str.bloodPressure
			setupPickerAndView(picker: bloodPressurePicker, viewTF: bloodPressurePTF, title: Str.bloodPressure)
			bloodPressurePTF.tfText = Str.sysDia(pressureData[0][bloodPressurePicker.selectedRow(inComponent: 0)], pressureData[1][bloodPressurePicker.selectedRow(inComponent: 1)])
			bloodPressurePTF.textfield.textColor = .black
		case .weight:
			title = Str.weight
			setupPickerAndView(picker: weightPicker, viewTF: weightPTF, title: Str.weight)
			setupPickerAndView(picker: goalWeightPicker, viewTF: goalWeightPTF, title: Str.goalWeight)
			weightPTF.tfText = Str.lbsDec(lbsData[0][weightPicker.selectedRow(inComponent: 0)], lbsData[1][weightPicker.selectedRow(inComponent: 1)])
			weightPTF.textfield.textColor = .black
			goalWeightPTF.tfText = Str.lbs(lbsData[0][goalWeightPicker.selectedRow(inComponent: 0)])
			goalWeightPTF.textfield.textColor = .black
		}
		setupObservation()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func populateData() {
		super.populateData()
	}

	private func setupPickerAndView(picker: UIPickerView, viewTF: PickerTF, title: String) {
		picker.delegate = self
		picker.dataSource = self
		for component in 0 ..< numberOfComponents(in: picker) {
			picker.selectRow(0, inComponent: component, animated: false)
		}

		if picker == weightPicker {
			picker.selectRow(125, inComponent: 0, animated: false)
			picker.selectRow(0, inComponent: 1, animated: false)
		}

		viewTF.setupValues(labelTitle: title, text: "")
		let tap = PickerTapGesture(target: self, action: #selector(managePicker))
		tap.picker = picker
		tap.viewTF = viewTF
		viewTF.addGestureRecognizer(tap)
		sv.addArrangedSubview(viewTF)
		sv.addArrangedSubview(picker)
		picker.isHidden = true

		fixLabelsInPlace(with: picker)
	}

	private func fixLabelsInPlace(with picker: UIPickerView) {
		let font = Font.sfProBold.of(size: 12)
		let fontSize: CGFloat = font.pointSize
		let componentWidth: CGFloat = view.frame.width / CGFloat(picker.numberOfComponents)
		let y = (picker.frame.size.height / 2) - (fontSize / 2)
		switch inputType {
		case .bloodPressure:
			let label = UILabel(frame: CGRect(x: componentWidth * 0.625, y: y, width: componentWidth * 0.4, height: fontSize))
			label.font = font
			label.textAlignment = .left
			label.text = Str.sys
			label.textColor = .black
			picker.addSubview(label)

			let label2 = UILabel(frame: CGRect(x: componentWidth * 1.65, y: y, width: componentWidth * 0.4, height: fontSize))
			label2.font = font
			label2.textAlignment = .left
			label2.text = Str.dia
			label2.textColor = .black
			picker.addSubview(label2)
		case .weight:
			let label = UILabel(frame: CGRect(x: componentWidth * 0.6, y: y, width: componentWidth * 0.4, height: fontSize))
			label.font = font
			label.textAlignment = .left
			label.text = Str.lb
			label.textColor = .black
			picker.addSubview(label)
		}
	}

	private func setupDatePickerAndView(picker: UIDatePicker, viewTF: PickerTF, title: String) {
		viewTF.setupValues(labelTitle: title, text: "")
		let tap = PickerTapGesture(target: self, action: #selector(managePicker))
		tap.datePicker = picker
		tap.viewTF = viewTF
		viewTF.addGestureRecognizer(tap)
		sv.addArrangedSubview(viewTF)
		sv.addArrangedSubview(picker)
		picker.isHidden = true
	}

	private func setupObservation() {
		var effectiveDateTime = ""
		if let date = DataContext.shared.getDate() {
			effectiveDateTime = DateFormatter.wholeDateRequest.string(from: date)
		} else {
			return
		}
		switch inputType {
		case .bloodPressure:
			inputAction?(bloodPressurePicker.selectedRow(inComponent: 0), bloodPressurePicker.selectedRow(inComponent: 1), effectiveDateTime, inputType)
		case .weight:
			inputAction?(weightPicker.selectedRow(inComponent: 0), goalWeightPicker.selectedRow(inComponent: 0), effectiveDateTime, inputType)
		}
	}

	@objc func managePicker(sender: PickerTapGesture) {
		guard let viewTF = sender.viewTF else { return }
		let picker = (sender.picker == nil) ? sender.datePicker : sender.picker

		if let picker = picker {
			UIPickerView.transition(with: picker, duration: 0.1,
			                        options: .curveEaseOut,
			                        animations: {
			                        	picker.isHidden.toggle()
			                        })
			viewTF.textfield.textColor = picker.isHidden ? .black : .lightGray
		}

		for view in sv.arrangedSubviews {
			if view != picker, view is UIPickerView || view is UIDatePicker {
				view.isHidden = true
			} else if view != viewTF, view is PickerTF {
				let view = view as! PickerTF
				view.textfield.textColor = .black
			}
		}
	}

	@objc private func datePickerDateChanged(_ sender: UIDatePicker) {
		datePTF.textfield.text = DateFormatter.ddMMyyyy.string(from: sender.date)
		setupObservation()
	}

	@objc private func timePickerDateChanged(_ sender: UIDatePicker) {
		timePTF.textfield.text = DateFormatter.hmma.string(from: sender.date)
		setupObservation()
	}
}

extension TodayInputVC: UIPickerViewDelegate, UIPickerViewDataSource {
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if pickerView == weightPicker {
			return component == 0 ? "\(lbsData[component][row])" : ".\(lbsData[component][row])"
		} else if pickerView == goalWeightPicker {
			return "\(lbsData[component][row])"
		} else if pickerView == bloodPressurePicker {
			return "\(pressureData[component][row])"
		}

		return ""
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if pickerView == weightPicker {
			var text = ""
			if component == 0 {
				text = Str.lbsDec(lbsData[0][row], lbsData[1][pickerView.selectedRow(inComponent: 1)])
			} else {
				text = Str.lbsDec(lbsData[0][pickerView.selectedRow(inComponent: 0)], lbsData[1][row])
			}
			weightPTF.tfText = text
		} else if pickerView == goalWeightPicker {
			goalWeightPTF.tfText = Str.lbs(lbsData[0][row])
		} else if pickerView == bloodPressurePicker {
			var text = ""
			if component == 0 {
				text = Str.sysDia(pressureData[0][row], pressureData[1][pickerView.selectedRow(inComponent: 1)])
			} else {
				text = Str.sysDia(pressureData[0][pickerView.selectedRow(inComponent: 0)], pressureData[1][row])
			}
			bloodPressurePTF.tfText = text
		}
		setupObservation()
	}

	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		if pickerView == weightPicker || pickerView == bloodPressurePicker {
			return 2
		} else if pickerView == goalWeightPicker {
			return 1
		}
		return 1
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if pickerView == weightPicker || pickerView == goalWeightPicker {
			return lbsData[component].count
		} else if pickerView == bloodPressurePicker {
			return pressureData[component].count
		}
		return 0
	}
}
