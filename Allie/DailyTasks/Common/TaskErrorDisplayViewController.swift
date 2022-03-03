//
//  TaskErrorDisplayViewController.swift
//  Allie
//
//  Created by Waqar Malik on 5/14/21.
//

import CareModel
import UIKit

class TaskErrorDisplayViewController: UITableViewController {
	var items: [CHBasicTask] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Decode Error"

		tableView.showsVerticalScrollIndicator = false
		tableView.showsHorizontalScrollIndicator = false
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
		tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: UITableViewHeaderFooterView.reuseIdentifier)
		tableView.sectionHeaderHeight = 64.0
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		items.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
		let item = items[indexPath.row]
		cell.textLabel?.text = "Task Title: \(item.title ?? "") " + "\nId: \(item.id ?? "")"
		cell.textLabel?.numberOfLines = 0
		return cell
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: UITableViewHeaderFooterView.reuseIdentifier)
		view?.textLabel?.text = "There was an error decoding the follwing tasks"
		view?.textLabel?.numberOfLines = 0
		return view
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
