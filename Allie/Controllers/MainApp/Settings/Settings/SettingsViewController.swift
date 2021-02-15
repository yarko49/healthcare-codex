import UIKit

class SettingsViewController: BaseViewController {
	var didFinishAction: (() -> Void)?
	var logoutAction: (() -> Void)?
	var itemSelectionAction: ((SettingsType) -> Void)?

	// MARK: - Properties

	let rowHeight: CGFloat = 60
	let footerHeight: CGFloat = 110

	// MARK: - IBOutlets

	let tableView: UITableView = {
		let view = UITableView(frame: .zero, style: .plain)
		view.layoutMargins = UIEdgeInsets.zero
		view.separatorInset = UIEdgeInsets.zero
		view.separatorStyle = .singleLine
		view.isScrollEnabled = false
		return view
	}()

	let settingsFooterView: SettingsFooterView = {
		let view = SettingsFooterView(frame: .zero)
		return view
	}()

	var dataSource: UITableViewDiffableDataSource<Int, SettingsType>!

	// MARK: - Setup

	override func viewDidLoad() {
		super.viewDidLoad()
		title = Str.settings
		let leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .done, target: self, action: #selector(close(_:)))
		leftBarButtonItem.tintColor = .black
		navigationItem.leftBarButtonItem = leftBarButtonItem

		settingsFooterView.translatesAutoresizingMaskIntoConstraints = false
		settingsFooterView.delegate = self
		view.addSubview(settingsFooterView)
		NSLayoutConstraint.activate([settingsFooterView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: settingsFooterView.trailingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: settingsFooterView.bottomAnchor, multiplier: 0.0),
		                             settingsFooterView.heightAnchor.constraint(equalToConstant: footerHeight)])

		tableView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(tableView)
		NSLayoutConstraint.activate([tableView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 0.0),
		                             tableView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: tableView.trailingAnchor, multiplier: 0.0),
		                             settingsFooterView.topAnchor.constraint(equalToSystemSpacingBelow: tableView.bottomAnchor, multiplier: 0.0)])

		tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
		tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: UITableViewHeaderFooterView.reuseIdentifier)
		dataSource = UITableViewDiffableDataSource<Int, SettingsType>(tableView: tableView, cellProvider: { (tableView, indexPath, type) -> UITableViewCell? in
			let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
			cell.layoutMargins = UIEdgeInsets.zero
			cell.accessoryType = .disclosureIndicator
			cell.textLabel?.attributedText = type.title.with(style: .regular17, andColor: UIColor.grey, andLetterSpacing: -0.41)
			return cell
		})

		tableView.rowHeight = rowHeight
		tableView.delegate = self
		var snapshot = dataSource.snapshot()
		snapshot.appendSections([0])
		snapshot.appendItems(SettingsType.allCases, toSection: 0)
		dataSource.apply(snapshot, animatingDifferences: false) {
			ALog.info("Finished Apply Snapshot")
		}
	}

	@IBAction func close(_ sender: Any) {
		didFinishAction?()
	}
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		defer {
			tableView.deselectRow(at: indexPath, animated: true)
		}
		guard let item = dataSource.itemIdentifier(for: indexPath) else {
			return
		}
		itemSelectionAction?(item)
	}
}

extension SettingsViewController: SettingsFooterViewDelegate {
	func settingsFooterViewDidTapLogout(_ view: SettingsFooterView) {
		logoutAction?()
	}
}
