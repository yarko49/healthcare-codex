import Foundation
import IQKeyboardManagerSwift
import UIKit

enum Input: String, Codable {
	case height
	case weight
}

class ProfileDataEntryViewController: BaseViewController, UIGestureRecognizerDelegate {
	var alertAction: ((_ tv: PickerTextField) -> Void)?
	var patientRequestAction: ((_ resourceType: String, _ birthdate: Date?, _ weight: Int, _ height: Int, _ date: Date) -> Void)?

	@IBOutlet var infoLabel: UILabel!
	@IBOutlet var pickerStackView: UIStackView!
	@IBOutlet var nextButton: BottomButton!
	@IBOutlet var bottomView: UIView!

	var inputType: Input = .weight
	var dobDateString: String?
	var dateOfBirth: Date?
	var comingFrom: NavigationSourceType = .signUp
	let feetData = [Array(3 ... 8), Array(0 ... 12)]
	var feet: Int?
	var inches: Int?
	var totalHeight: Int?
	var lbData = Array(25 ... 300)
	var defaultIndexesFeetData = [2, 6]
	var defaultIndexLbData = 125
	var profileHeight: Int = 56
	var profileWeight: Int = 150
	var datePicker = UIDatePicker()
	var weightPicker = UIPickerView()
	var heightPicker = UIPickerView()
	var dateTextView = PickerTextField()
	var weightTextView = PickerTextField()
	var heightTextView = PickerTextField()

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "MyProfileSecondView"])
	}

	override func setupView() {
		super.setupView()
		setupDefaultIndexes()
		setupDatePicker()
		setupDatePickerAndView(picker: datePicker, viewTextField: dateTextView, title: Str.dob)
		setupPickerAndView(picker: heightPicker, viewTF: heightTextView, title: Str.height)
		setupPickerAndView(picker: weightPicker, viewTF: weightTextView, title: Str.weight)
		title = Str.profile
		infoLabel.attributedText = Str.information.with(style: .regular17, andColor: UIColor.lightGray, andLetterSpacing: -0.32)
		infoLabel.numberOfLines = 0
		nextButton.setAttributedTitle(Str.next.uppercased().with(style: .regular17, andColor: .white, andLetterSpacing: 5), for: .normal)
		nextButton.refreshCorners(value: 0)
		nextButton.setupButton()
		nextButton.backgroundColor = .next
		bottomView.backgroundColor = UIColor.next
		datePicker.addTarget(self, action: #selector(datePickerDateChanged(_:)), for: .valueChanged)

		view.isUserInteractionEnabled = true
		view.layoutIfNeeded()
	}

	func setupDefaultIndexes() {
		guard let selectedIndex = lbData.firstIndex(of: profileWeight) else {
			return
		}
		defaultIndexLbData = selectedIndex
		weightPicker.selectRow(selectedIndex, inComponent: 0, animated: false)

		let heightProfileString = String(profileHeight)
		if heightProfileString.isEmpty {
			feet = 3
			inches = 0
		} else if heightProfileString.count == 1 {
			feet = Int(heightProfileString)
			inches = 0
		} else if heightProfileString.count == 2 {
			feet = Int(heightProfileString.prefix(1))
			inches = Int(heightProfileString.suffix(1))
		} else {
			feet = Int(heightProfileString.prefix(1))
			inches = Int(heightProfileString.suffix(2))
		}

		guard let selectedIndexFt = feetData[0].firstIndex(of: feet ?? 2) else {
			return
		}

		guard let selectedIndexInch = feetData[1].firstIndex(of: inches ?? 6) else {
			return
		}

		defaultIndexesFeetData = [selectedIndexFt, selectedIndexInch]
	}

	func setupDatePicker() {
		let picker = UIDatePicker()
		let birthDate = AppDelegate.careManager.patient?.birthday
		var defaultDate = Date()
		let calendar = Calendar(identifier: .gregorian)
		var components = DateComponents()
		components.year = 1970
		components.month = 1
		components.day = 1
		defaultDate = calendar.date(from: components) ?? Date()
		picker.datePickerMode = .date
		picker.backgroundColor = UIColor.white
		components.year = -50
		components.month = 0
		components.day = 0
		let minDate = calendar.date(byAdding: components as DateComponents, to: defaultDate)
		components.year = 70
		let maxDate = calendar.date(byAdding: components as DateComponents, to: defaultDate)
		picker.minimumDate = minDate
		picker.maximumDate = maxDate
		picker.setDate(birthDate ?? defaultDate, animated: false)
		if #available(iOS 13.4, *) {
			picker.preferredDatePickerStyle = .wheels
		}
		datePicker = picker
	}

	private func setupPickerAndView(picker: UIPickerView, viewTF: PickerTextField, title: String) {
		picker.delegate = self
		picker.dataSource = self
		for component in 0 ..< numberOfComponents(in: picker) {
			picker.selectRow(0, inComponent: component, animated: false)
		}
		if picker == weightPicker {
			viewTF.setupValues(labelTitle: title, text: Str.lbs(profileWeight))
			picker.selectRow(defaultIndexLbData, inComponent: 0, animated: false)
		} else if picker == heightPicker {
			if profileHeight >= 100 {
				viewTF.setupValues(labelTitle: title, text: "\(profileHeight / 100) ft \(profileHeight % 100)")
				picker.selectRow(defaultIndexesFeetData[0], inComponent: 0, animated: false)
				picker.selectRow(defaultIndexesFeetData[1], inComponent: 1, animated: false)
			} else {
				viewTF.setupValues(labelTitle: title, text: "\(profileHeight / 10) ft \(profileHeight % 10)")
				picker.selectRow(defaultIndexesFeetData[0], inComponent: 0, animated: false)
				picker.selectRow(defaultIndexesFeetData[1], inComponent: 1, animated: false)
			}
		}
		viewTF.textfield.textColor = .black

		let tap = PickerTapGesture(target: self, action: #selector(managePicker))
		tap.picker = picker
		tap.textFieldView = viewTF
		viewTF.addGestureRecognizer(tap)
		pickerStackView.addArrangedSubview(viewTF)
		pickerStackView.addArrangedSubview(picker)
		picker.isHidden = true

		fixLabelsInPlace(with: picker)
	}

	private func setupDatePickerAndView(picker: UIDatePicker, viewTextField: PickerTextField, title: String) {
		var birthdayString = ""
		if let birthday = AppDelegate.careManager.patient?.birthday {
			birthdayString = DateFormatter.yyyyMMdd.string(from: birthday)
		}
		viewTextField.setupValues(labelTitle: title, text: birthdayString)
		let tap = PickerTapGesture(target: self, action: #selector(managePicker))
		tap.datePicker = picker
		tap.textFieldView = viewTextField
		dateTextView.state = .normal
		viewTextField.addGestureRecognizer(tap)
		pickerStackView.addArrangedSubview(viewTextField)
		pickerStackView.addArrangedSubview(picker)
		picker.isHidden = true
		datePickerDateChanged(datePicker)
		dateTextView.textfield.textColor = .black
	}

	@objc func managePicker(sender: PickerTapGesture) {
		guard let viewTF = sender.textFieldView else { return }
		let picker = (sender.picker == nil) ? sender.datePicker : sender.picker

		if let picker = picker {
			UIPickerView.transition(with: picker, duration: 0.1, options: .curveEaseOut, animations: {
				picker.isHidden.toggle()
			})

			viewTF.textfield.textColor = picker.isHidden ? .black : .lightGray
		}

		for view in pickerStackView.arrangedSubviews {
			if view != picker, view is UIPickerView || view is UIDatePicker {
				view.isHidden = true
			} else if let view = view as? PickerTextField, view != viewTF {
				view.textfield.textColor = .black
			}
		}
	}

	private func setupObservation() {}

	private func fixLabelsInPlace(with picker: UIPickerView) {
		let font = UIFont.systemFont(ofSize: 12.0, weight: .bold)
		let fontSize: CGFloat = font.pointSize
		let componentWidth: CGFloat = view.frame.width / CGFloat(picker.numberOfComponents)
		let yPos = (picker.frame.size.height / 2) - (fontSize / 2)

		if picker == heightPicker {
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
		} else if picker == weightPicker {
			let label = UILabel(frame: CGRect(x: componentWidth * 0.6, y: yPos, width: componentWidth * 0.4, height: fontSize))
			label.font = font
			label.textAlignment = .left
			label.text = Str.lb
			label.textColor = .black
			picker.addSubview(label)
		}
	}

	@objc private func datePickerDateChanged(_ sender: UIDatePicker) {
		let calendarDate = DateFormatter.ddMMyyyy.string(from: sender.date)
		dateTextView.textfield.attributedText = calendarDate.with(style: .regular20, andColor: .lightGray, andLetterSpacing: -0.41)
		dobDateString = DateFormatter.yyyyMMdd.string(from: sender.date)
		dateTextView.state = .normal
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		view.endEditing(true)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	@IBAction func nextBtnTapped(_ sender: Any) {
		let views = [dateTextView, heightTextView, weightTextView]
		for view in views {
			guard let tf = view.tfText, !tf.isEmpty else {
				view.state = .error
				alertAction?(view)
				return
			}
			view.state = .normal
		}

		setupObservation()
		let startOfDay = Calendar.current.startOfDay(for: Date())
		patientRequestAction?("Patient", dateOfBirth, profileWeight, profileHeight, startOfDay)
	}
}

extension ProfileDataEntryViewController: UIPickerViewDataSource {
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		if pickerView == datePicker {
			return 3
		} else if pickerView == heightPicker {
			return 2
		} else {
			return 1
		}
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		var data = 0
		if pickerView == heightPicker {
			data = feetData[component].count
		} else if pickerView == weightPicker {
			data = lbData.count
		}
		return data
	}
}

extension ProfileDataEntryViewController: UIPickerViewDelegate {
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		var rowData: String = ""

		if pickerView == heightPicker {
			rowData = "\(feetData[component][row])"
		} else if pickerView == weightPicker {
			rowData = "\(lbData[row])"
		}
		return rowData
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		var stringHeight: String = ""
		if pickerView == weightPicker {
			profileWeight = lbData[row]
			weightTextView.tfText = Str.lbs(lbData[row])
			weightTextView.state = .normal
		} else if pickerView == heightPicker {
			feet = feetData[0][pickerView.selectedRow(inComponent: 0)]
			inches = feetData[1][pickerView.selectedRow(inComponent: 1)]
			if let ft = feet, let inc = inches {
				totalHeight = ft * 12 + inc
				stringHeight = String(ft) + String(inc)
				profileHeight = Int(stringHeight) ?? 56
				heightTextView.tfText = "\(ft) ft \(inc)"
				heightTextView.state = .normal
			} else {}
		}
	}
}
