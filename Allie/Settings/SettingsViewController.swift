import AnswerBotSDK
import ChatSDK
import MessagingSDK
import SafariServices
import SDKConfigurations
import SupportSDK
import UIKit

class SettingsViewController: BaseViewController {
	let rowHeight: CGFloat = 60
	let footerHeight: CGFloat = 110

	// MARK: - IBOutlets

	let tableView: UITableView = {
		let view = UITableView(frame: .zero, style: .plain)
		view.layoutMargins = UIEdgeInsets.zero
		view.separatorInset = UIEdgeInsets.zero
		view.separatorStyle = .singleLine
		view.isScrollEnabled = false
		view.tableFooterView = UIView()
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
			cell.tintColor = .allieButtons
			cell.layoutMargins = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
			cell.accessoryType = .disclosureIndicator
			cell.textLabel?.attributedText = type.title.with(style: .regular17, andColor: .allieButtons, andLetterSpacing: -0.41)
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

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "SettingsView"])
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

		switch item {
		case .accountDetails:
			showAccountDetails()
		case .myDevices:
			showMyDevices()
		case .notifications:
			showNotifications()
		case .systemAuthorization:
			showSystemAuthorization()
		case .feedback:
			showFeedback()
		case .privacyPolicy:
			showPrivacyPolicy()
		case .termsOfService:
			showTermsOfService()
		case .support:
			showSupport()
		case .troubleShoot:
			showHelpCenter()
		}
	}

	func showAccountDetails() {
		let profileEntryViewController = ProfileEntryViewController()
		profileEntryViewController.patient = AppDelegate.careManager.patient
		profileEntryViewController.doneAction = {
			var alliePatient = AppDelegate.careManager.patient
			if let name = PersonNameComponents(fullName: profileEntryViewController.fullName) {
				alliePatient?.name = name
			}
			alliePatient?.sex = profileEntryViewController.sex
			alliePatient?.updatedDate = Date()
			alliePatient?.birthday = profileEntryViewController.dateOfBirth
			alliePatient?.profile.weightInPounds = profileEntryViewController.weightInPounds
			alliePatient?.profile.heightInInches = profileEntryViewController.heightInInches
			// upload Patient
		}
		navigationController?.show(profileEntryViewController, sender: self)
	}

	func showMyDevices() {
		let devicesViewController = DevicesSelectionViewController()
		devicesViewController.title = NSLocalizedString("MY_DEVICES", comment: "My Devices")
		navigationController?.show(devicesViewController, sender: self)
	}

	func showNotifications() {
		let myNotificationsViewController = NotificationSettingsController()
		navigationController?.show(myNotificationsViewController, sender: self)
	}

	func showSystemAuthorization() {
		if let url = URL(string: UIApplication.openSettingsURLString) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}

	func showFeedback() {
		let config = RequestUiConfiguration()
		config.subject = "iOS Ticket"
		config.tags = ["ios", "mobile"]
		let requestListController = RequestUi.buildRequestList(with: [config])
		navigationController?.show(requestListController, sender: self)
	}

	func showHelpCenter() {
		guard let url = URL(string: "https://codexhealth.zendesk.com/hc/en-us") else {
			return
		}
		let safarViewController = SFSafariViewController(url: url)
		safarViewController.delegate = self
		navigationController?.showDetailViewController(safarViewController, sender: self)
	}

	func showSupport() {
		do {
			let messagingConfiguration = MessagingConfiguration()
			let answerBotEngine = try AnswerBotEngine.engine()
			let supportEngine = try SupportEngine.engine()
			let chatEngine = try ChatEngine.engine()
			let viewController = try Messaging.instance.buildUI(engines: [supportEngine, chatEngine, answerBotEngine], configs: [messagingConfiguration])
			navigationController?.show(viewController, sender: self)
		} catch {
			ALog.error("Unable to show support", error: error)
		}
	}

	func showMailSetupAlert() {
		let title = NSLocalizedString("NO_EMAIL_SETUP.title", comment: "Email Setup")
		let message = NSLocalizedString("NO_EMAIL_SETUP.message", comment: "Please setup default email!")
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let cancelTitle = NSLocalizedString("CANCEL", comment: "Cancel")
		let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { _ in
		}
		alertController.addAction(cancelAction)
		navigationController?.show(alertController, sender: self)
	}

	func showPrivacyPolicy() {
		let privacyPolicyViewController = HTMLViewerController()
		privacyPolicyViewController.title = Str.privacyPolicy
		navigationController?.show(privacyPolicyViewController, sender: self)
	}

	func showTermsOfService() {
		let termsOfServiceViewController = HTMLViewerController()
		termsOfServiceViewController.title = Str.termsOfService
		navigationController?.show(termsOfServiceViewController, sender: self)
	}
}

extension SettingsViewController: SettingsFooterViewDelegate {
	func settingsFooterViewDidTapLogout(_ view: SettingsFooterView) {
		NotificationCenter.default.post(name: .applicationDidLogout, object: nil)
	}
}

extension SettingsViewController: SFSafariViewControllerDelegate {}
