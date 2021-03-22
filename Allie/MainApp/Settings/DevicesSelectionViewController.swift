//
//  DevicesViewController.swift
//  Allie
//
//  Created by Waqar Malik on 3/20/21.
//

import UIKit

class DevicesSelectionViewController: BaseViewController, UITableViewDelegate {
	var nextButtonAction: Coordinable.ActionHandler?

	var dataSource: UITableViewDiffableDataSource<Int, SmartDeviceType>!

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(tableView)
		nextButton.translatesAutoresizingMaskIntoConstraints = false
		buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
		buttonContainerView.addSubview(nextButton)
		view.addSubview(buttonContainerView)
		NSLayoutConstraint.activate([nextButton.leadingAnchor.constraint(equalToSystemSpacingAfter: buttonContainerView.leadingAnchor, multiplier: 0.0),
		                             nextButton.topAnchor.constraint(equalToSystemSpacingBelow: buttonContainerView.topAnchor, multiplier: 0.0),
		                             buttonContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: nextButton.trailingAnchor, multiplier: 0.0),
		                             nextButton.heightAnchor.constraint(equalToConstant: 60.0)])

		NSLayoutConstraint.activate([buttonContainerView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0.0),
		                             view.bottomAnchor.constraint(equalToSystemSpacingBelow: buttonContainerView.bottomAnchor, multiplier: 0.0),
		                             buttonContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.trailingAnchor, multiplier: 0.0),
		                             buttonContainerView.heightAnchor.constraint(equalToConstant: 94.0)])
		NSLayoutConstraint.activate([tableView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 0.0),
		                             tableView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: tableView.trailingAnchor, multiplier: 0.0),
		                             buttonContainerView.topAnchor.constraint(equalToSystemSpacingBelow: tableView.bottomAnchor, multiplier: 0.0)])

		tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
		dataSource = UITableViewDiffableDataSource<Int, SmartDeviceType>(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, deviceType in
			let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
			let accessoryView = UISwitch(frame: .zero)
			accessoryView.addTarget(self, action: #selector(self?.didSelectSwitch(_:forEvent:)), for: .valueChanged)
			accessoryView.isOn = deviceType.hasSmartDevice
			accessoryView.tag = indexPath.row
			cell.accessoryView = accessoryView
			cell.textLabel?.attributedText = deviceType.title.with(style: .regular17, andColor: UIColor.grey, andLetterSpacing: -0.41)
			return cell
		})
		tableView.dataSource = dataSource
		tableView.delegate = self
		var snapshot = NSDiffableDataSourceSnapshot<Int, SmartDeviceType>()
		snapshot.appendSections([0])
		snapshot.appendItems(SmartDeviceType.allCases)
		dataSource.apply(snapshot, animatingDifferences: false) {
			ALog.info("Did finish applying snapshot")
		}

		nextButton.addTarget(self, action: #selector(didSelectNext(_:)), for: .touchUpInside)
	}

	let tableView: UITableView = {
		let view = UITableView(frame: .zero, style: .plain)
		view.isScrollEnabled = true
		view.layoutMargins = UIEdgeInsets.zero
		view.separatorInset = UIEdgeInsets.zero
		view.tableFooterView = UIView()
		view.separatorStyle = .singleLine
		view.allowsSelection = false
		return view
	}()

	let buttonContainerView: UIView = {
		let view = UIView(frame: .zero)
		view.backgroundColor = .next
		return view
	}()

	let nextButton: BottomButton = {
		let button = BottomButton(type: .system)
		button.backgroundColor = UIColor.next
		button.setAttributedTitle(Str.next.uppercased().with(style: .regular17, andColor: .white, andLetterSpacing: 5), for: .normal)
		button.refreshCorners(value: 0)
		return button
	}()

	@IBAction func didSelectNext(_ sender: UIButton) {
		nextButtonAction?()
	}

	@IBAction func didSelectSwitch(_ sender: UISwitch, forEvent event: UIEvent) {
		let indexPath = IndexPath(row: sender.tag, section: 0)
		var device = dataSource.itemIdentifier(for: indexPath)
		device?.hasSmartDevice.toggle()
	}

	func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		false
	}

	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		nil
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
