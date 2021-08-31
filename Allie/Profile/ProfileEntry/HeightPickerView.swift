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

	override func viewDidLoad() {
		super.viewDidLoad()

		title = NSLocalizedString("HEIGHT", comment: "Height")
		let effect = UIBlurEffect(style: .light)
		let effectView = UIVisualEffectView(effect: effect)
		effectView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(effectView)
		NSLayoutConstraint.activate([effectView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 0.0),
		                             effectView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: effectView.trailingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: effectView.bottomAnchor, multiplier: 0.0)])
		view.addSubview(heightPickerView)
		NSLayoutConstraint.activate([heightPickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		                             heightPickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
		let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
		navigationItem.leftBarButtonItem = cancelButton

		let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save(_:)))
		navigationItem.rightBarButtonItem = saveButton

		let feetIndex = heightData[0].firstIndex(of: heightInInches / 12)
		let inchesIndex = heightData[1].firstIndex(of: heightInInches % 12)
		heightPickerView.selectRow(feetIndex ?? 2, inComponent: 0, animated: false)
		heightPickerView.selectRow(inchesIndex ?? 6, inComponent: 1, animated: false)
		fixLabelsInPlace()
	}

	let heightData = [Array(3 ... 8), Array(0 ... 12)]
	var heightInInches: Int = 66

	lazy var heightPickerView: UIPickerView = {
		let picker = UIPickerView(frame: .zero)
		picker.translatesAutoresizingMaskIntoConstraints = false
		picker.dataSource = self
		picker.delegate = self
		return picker
	}()

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

	@IBAction private func cancel(_ sender: Any?) {
		dismiss(animated: true, completion: nil)
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
