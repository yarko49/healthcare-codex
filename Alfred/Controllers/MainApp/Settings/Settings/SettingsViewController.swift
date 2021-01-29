import UIKit

class SettingsViewController: BaseViewController {
	var accountDetailsAction: (() -> Void)?
	var myDevicesAction: (() -> Void)?
	var notificationsAction: (() -> Void)?
	var systemAuthorizationAction: (() -> Void)?
	var feedbackAction: (() -> Void)?
	var privacyPolicyAction: (() -> Void)?
	var termsOfServiceAction: (() -> Void)?
	var logoutAction: (() -> Void)?

	// MARK: - Properties

	var settings: [SettingsType] = SettingsType.allCases
	let rowHeight: CGFloat = 60
	let footerHeight: CGFloat = 110

	// MARK: - IBOutlets

	@IBOutlet var settingsTV: UITableView!

	// MARK: - Setup

	override func setupView() {
		super.setupView()
		title = Str.settings
		setupTableView()
		setupFooter()
	}

	private func setupTableView() {
		settingsTV.register(UINib(nibName: SettingsCell.nibName, bundle: nil), forCellReuseIdentifier: SettingsCell.reuseIdentifier)
		settingsTV.rowHeight = rowHeight
		settingsTV.dataSource = self
		settingsTV.delegate = self
		settingsTV.isScrollEnabled = true
		settingsTV.layoutMargins = UIEdgeInsets.zero
		settingsTV.separatorInset = UIEdgeInsets.zero
	}

	private func setupFooter() {
		let settingsFooter = SettingsFooterView(viewHeight: footerHeight)
		settingsFooter.delegate = self
		settingsTV.tableFooterView = settingsFooter
		settingsTV.separatorStyle = .singleLine
	}

	override func populateData() {
		super.populateData()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		guard let footerView = settingsTV.tableFooterView else {
			return
		}

		let guide = view.safeAreaLayoutGuide
		let height = guide.layoutFrame.size.height
		let heightCheck = height - CGFloat(settings.count) * rowHeight
		let fHeight = heightCheck < footerHeight ? footerHeight : heightCheck
		if footerView.frame.size.height != fHeight {
			footerView.frame.size.height = fHeight
			settingsTV.tableFooterView = footerView
		}
	}

	// MARK: - Actions
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		settings.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.reuseIdentifier, for: indexPath) as? SettingsCell
		cell?.layoutMargins = UIEdgeInsets.zero

		cell?.setup(name: settings[indexPath.row].description)
		return cell!
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch settings[indexPath.row] {
		case .accountDetails:
			accountDetailsAction?()
		case .myDevices:
			myDevicesAction?()
		case .notifications:
			notificationsAction?()
		case .systemAuthorization:
			systemAuthorizationAction?()
		case .feedback:
			feedbackAction?()
		case .privacyPolicy:
			privacyPolicyAction?()
		case .termsOfService:
			termsOfServiceAction?()
		}
	}
}

extension SettingsViewController: SettingsFooterViewDelegate {
	func didTapLogout() {
		logoutAction?()
	}
}
