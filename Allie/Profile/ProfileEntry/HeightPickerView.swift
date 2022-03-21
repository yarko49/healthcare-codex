//
//  HeightPickerView.swift
//  Allie
//
//  Created by Waqar Malik on 8/30/21.
//

import UIKit

protocol HeightPickerViewDelegate: AnyObject {
	func heightPickerViewDidSave(_ picker: HeightPickerView)
}

class HeightPickerView: UIViewController {
	weak var delegate: HeightPickerViewDelegate?

	let heightData = [Array(3 ... 8), Array(0 ... 12)]
	var heightInInches: Int = 66

	lazy var heightPickerView: UIPickerView = {
		let picker = UIPickerView(frame: .zero)
		picker.translatesAutoresizingMaskIntoConstraints = false
		picker.dataSource = self
		picker.delegate = self
		return picker
	}()

	private let doneButton: BottomButton = {
		let doneButton = BottomButton()
		doneButton.translatesAutoresizingMaskIntoConstraints = false
		doneButton.backgroundColor = .black
		doneButton.cornerRadius = 4.0
		doneButton.setAttributedTitle(NSLocalizedString("DONE", comment: "Done").attributedString(style: .silkabold16, foregroundColor: UIColor.white), for: .normal)
		return doneButton
	}()

	private let contentVStack: UIStackView = {
		let contentVStack = UIStackView()
		contentVStack.translatesAutoresizingMaskIntoConstraints = false
		contentVStack.axis = .vertical
		contentVStack.alignment = .fill
		contentVStack.distribution = .fill
		contentVStack.spacing = 20.0
		return contentVStack
	}()

	private let contentView: UIView = {
		let contentView = UIView()
		contentView.translatesAutoresizingMaskIntoConstraints = false
		contentView.backgroundColor = .white
		return contentView
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor(hex: "#F7FBFF")?.withAlphaComponent(0.5)

		setupViews()

		let feetIndex = heightData[0].firstIndex(of: heightInInches / 12)
		let inchesIndex = heightData[1].firstIndex(of: heightInInches % 12)
		heightPickerView.selectRow(feetIndex ?? 2, inComponent: 0, animated: false)
		heightPickerView.selectRow(inchesIndex ?? 6, inComponent: 1, animated: false)
		fixLabelsInPlace()
	}

	private func setupViews() {
		view.addSubview(contentView)
		NSLayoutConstraint.activate([contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		                             contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		                             contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor)])

		contentView.addSubview(contentVStack)
		NSLayoutConstraint.activate([contentVStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
		                             contentVStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
		                             contentVStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
		                             contentVStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30)])

		[heightPickerView, doneButton].forEach { contentVStack.addArrangedSubview($0) }
		NSLayoutConstraint.activate([doneButton.heightAnchor.constraint(equalToConstant: 48)])

		doneButton.addTarget(self, action: #selector(save), for: .touchUpInside)
	}

	private func fixLabelsInPlace() {
		let picker = heightPickerView
		let font = UIFont.systemFont(ofSize: 12.0, weight: .bold)
		let fontSize: CGFloat = font.pointSize
		let componentWidth: CGFloat = view.frame.width / CGFloat(picker.numberOfComponents)
		let yPos = (picker.frame.size.height / 2) - (fontSize / 2)

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
	}

	@IBAction private func save(_ sender: Any?) {
		delegate?.heightPickerViewDidSave(self)
	}
}

extension HeightPickerView: UIPickerViewDataSource, UIPickerViewDelegate {
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		2
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		heightData[component].count
	}

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		"\(heightData[component][row])"
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		let feet = heightData[0][pickerView.selectedRow(inComponent: 0)]
		let inches = heightData[1][pickerView.selectedRow(inComponent: 1)]
		heightInInches = feet * 12 + inches
	}
}
