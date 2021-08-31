//
//  WeightPickerView.swift
//  Allie
//
//  Created by Waqar Malik on 8/30/21.
//

import UIKit

protocol WeightPickerViewDelegate: AnyObject {
	func weightPickerViewDidSave(_ picker: WeightPickerView)
}

class WeightPickerView: UIViewController {
	weak var delegate: WeightPickerViewDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()
		title = NSLocalizedString("WEIGHT", comment: "Weight")
		let effect = UIBlurEffect(style: .light)
		let effectView = UIVisualEffectView(effect: effect)
		effectView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(effectView)
		NSLayoutConstraint.activate([effectView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 0.0),
		                             effectView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: effectView.trailingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: effectView.bottomAnchor, multiplier: 0.0)])
		view.addSubview(weightPickerView)
		NSLayoutConstraint.activate([weightPickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		                             weightPickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
		let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
		navigationItem.leftBarButtonItem = cancelButton

		let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save(_:)))
		navigationItem.rightBarButtonItem = saveButton

		let weightIndex = weightDataInPounds.firstIndex(of: weightInPounds)
		weightPickerView.selectRow(weightIndex ?? 125, inComponent: 0, animated: false)
		fixLabelsInPlace()
	}

	lazy var weightPickerView: UIPickerView = {
		let picker = UIPickerView(frame: .zero)
		picker.dataSource = self
		picker.delegate = self
		picker.translatesAutoresizingMaskIntoConstraints = false
		return picker
	}()

	var weightDataInPounds = Array(25 ... 300)
	var weightInPounds: Int = 150

	@IBAction private func cancel(_ sender: Any?) {
		dismiss(animated: true, completion: nil)
	}

	@IBAction private func save(_ sender: Any?) {
		delegate?.weightPickerViewDidSave(self)
	}

	private func fixLabelsInPlace() {
		let picker = weightPickerView
		let font = UIFont.systemFont(ofSize: 12.0, weight: .bold)
		let fontSize: CGFloat = font.pointSize
		let componentWidth: CGFloat = view.frame.width / CGFloat(picker.numberOfComponents)
		let yPos = (picker.frame.size.height / 2) - (fontSize / 2)

		let label = UILabel(frame: CGRect(x: componentWidth * 0.6, y: yPos, width: componentWidth * 0.4, height: fontSize))
		label.font = font
		label.textAlignment = .left
		label.text = String.lb
		label.textColor = .black
		picker.addSubview(label)
	}
}

extension WeightPickerView: UIPickerViewDataSource, UIPickerViewDelegate {
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		1
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		weightDataInPounds.count
	}

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		"\(weightDataInPounds[row])"
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		weightInPounds = weightDataInPounds[row]
	}
}
