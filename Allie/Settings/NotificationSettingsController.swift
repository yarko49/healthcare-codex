//
//  NotificationSettingsController.swift
//  Allie
//
//  Created by Waqar Malik on 3/21/21.
//

import UIKit

class NotificationSettingsController: BaseViewController, UITableViewDelegate {
	var dataSource: UITableViewDiffableDataSource<Int, NotificationType>!

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

	override func viewDidLoad() {
		super.viewDidLoad()
		title = String.myNotifications
		tableView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(tableView)
		NSLayoutConstraint.activate([tableView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 0.0),
		                             tableView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: tableView.trailingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: tableView.bottomAnchor, multiplier: 0.0)])

		tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
		dataSource = UITableViewDiffableDataSource<Int, NotificationType>(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, notificaionType in
			let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
			let accessoryView = UISwitch(frame: .zero)
			accessoryView.addTarget(self, action: #selector(self?.didSelectSwitch(_:forEvent:)), for: .valueChanged)
			accessoryView.isOn = notificaionType.isEnabled
			accessoryView.tag = indexPath.row
			cell.accessoryView = accessoryView
			cell.textLabel?.attributedText = notificaionType.title.with(style: .regular17, andColor: UIColor.grey, andLetterSpacing: -0.41)
			return cell
		})
		tableView.rowHeight = 60.0
		tableView.dataSource = dataSource
		tableView.delegate = self
		var snapshot = NSDiffableDataSourceSnapshot<Int, NotificationType>()
		snapshot.appendSections([0])
		snapshot.appendItems(NotificationType.allCases)
		dataSource.apply(snapshot, animatingDifferences: false) {
			ALog.info("Did finish applying snapshot")
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "MyNotificationsView"])
	}

	@IBAction func didSelectSwitch(_ sender: UISwitch, forEvent event: UIEvent) {
		let indexPath = IndexPath(row: sender.tag, section: 0)
		var notificationType = dataSource.itemIdentifier(for: indexPath)
		notificationType?.isEnabled.toggle()
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
