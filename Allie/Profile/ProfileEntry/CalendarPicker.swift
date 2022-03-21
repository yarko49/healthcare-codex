//
//  CalendarPicker.swift
//  Allie
//
//  Created by SwiftDev on 3/14/22.
//

import UIKit

class CalendarPicker: UIViewController {
	var onClickDoneAction: ((Date) -> Void)?

	var epoch: Date = .init(timeIntervalSince1970: 0)

	var datePicker: UIDatePicker = {
		let picker = UIDatePicker()
		picker.translatesAutoresizingMaskIntoConstraints = false
		let calendar = Calendar.current
		picker.datePickerMode = .date
		var dateComponents = DateComponents()
		let epoch = Date(timeIntervalSince1970: 0)
		dateComponents.year = -50
		dateComponents.month = 0
		dateComponents.day = 0
		picker.minimumDate = calendar.date(byAdding: dateComponents, to: epoch)
		dateComponents.year = 70
		picker.maximumDate = calendar.date(byAdding: dateComponents, to: epoch)
		picker.preferredDatePickerStyle = .wheels
		picker.backgroundColor = .clear
		picker.setValue(UIColor.black, forKey: "textColor")
		picker.setValue(false, forKey: "highlightsToday")
		picker.setValue(UIColor.clear, forKey: "backgroundColor")
		return picker
	}()

	private let highlightView: UIView = {
		let highlightView = UIView()
		highlightView.translatesAutoresizingMaskIntoConstraints = false
		highlightView.backgroundColor = .mainBlue
		highlightView.layer.cornerRadius = 4.0
		return highlightView
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
		datePicker.setDate(epoch, animated: false)
		setupViews()
	}

	private func setupViews() {
		[highlightView, contentView].forEach { view.addSubview($0) }
		NSLayoutConstraint.activate([contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		                             contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		                             contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor)])

		contentView.addSubview(contentVStack)
		NSLayoutConstraint.activate([contentVStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
		                             contentVStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
		                             contentVStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
		                             contentVStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30)])

		[datePicker, doneButton].forEach { contentVStack.addArrangedSubview($0) }

		NSLayoutConstraint.activate([highlightView.centerYAnchor.constraint(equalTo: datePicker.centerYAnchor),
		                             highlightView.heightAnchor.constraint(equalToConstant: 48),
		                             highlightView.widthAnchor.constraint(equalTo: contentVStack.widthAnchor),
		                             highlightView.centerXAnchor.constraint(equalTo: datePicker.centerXAnchor)])

		NSLayoutConstraint.activate([doneButton.heightAnchor.constraint(equalToConstant: 48)])

		doneButton.addTarget(self, action: #selector(onClickDoneButton), for: .touchUpInside)
	}

	@objc func onClickDoneButton() {
		dismiss(animated: true) { [weak self] in
			self?.onClickDoneAction?((self?.datePicker.date)!)
		}
	}
}
