import CodexFoundation
import Firebase
import FirebaseAuth
import KeychainAccess
import MessageUI
import MessagingSDK
import SafariServices
import SDKConfigurations
import SupportSDK
import SwiftUI
import UIKit

class SettingsViewController: BaseViewController {
	let rowHeight: CGFloat = 74
	let footerHeight: CGFloat = 160

	@Injected(\.careManager) var careManager: CareManager

	// MARK: - IBOutlets

	let tableView: UITableView = {
		let view = UITableView(frame: .zero, style: .plain)
		view.layoutMargins = UIEdgeInsets.zero
		view.separatorStyle = .none
		view.isScrollEnabled = true
		view.backgroundColor = .clear
		view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		return view
	}()

	let settingsFooterView: SettingsFooterView = {
		let view = SettingsFooterView(frame: .zero)
		return view
	}()

	var dataSource: UITableViewDiffableDataSource<Int, SettingsType>!
	@Injected(\.networkAPI) var networkAPI: AllieAPI
	@Injected(\.keychain) var keychain: Keychain
	var availableUpdateZendDisk: Bool = false

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .mainBackground
		tableView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(tableView)
		NSLayoutConstraint.activate([tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
		                             tableView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: tableView.trailingAnchor, multiplier: 0.0),
		                             tableView.bottomAnchor.constraint(equalToSystemSpacingBelow: view.bottomAnchor, multiplier: 0.0)])
		tableView.register(SettingCell.self, forCellReuseIdentifier: SettingCell.cellID)
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
		settingsFooterView.delegate = self
		dataSource = UITableViewDiffableDataSource<Int, SettingsType>(tableView: tableView, cellProvider: { tableView, indexPath, type -> UITableViewCell? in
			if indexPath.section == 0 {
				if let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.cellID, for: indexPath) as? SettingCell {
					cell.selectionStyle = .none
					cell.configureCell(type: type)
					return cell
				}
				fatalError("could not dequee cell")
			} else {
				let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
				cell.selectionStyle = .none
				cell.backgroundColor = .clear
				return cell
			}
		})
		tabBarController?.tabBar.items![3].badgeValue = "99"
		tableView.rowHeight = rowHeight
		tableView.delegate = self
		var snapshot = dataSource.snapshot()
		snapshot.appendSections([0])
		let items: [SettingsType] = [.accountDetails, .myDevices, .systemAuthorization, .feedback, .privacyPolicy, .termsOfService, .providers, .logging]
		snapshot.appendItems(items, toSection: 0)
		snapshot.appendSections([1])
		dataSource.apply(snapshot, animatingDifferences: false) {
			ALog.info("Finished Apply Snapshot")
		}
		if LoggingManager.isFileLogginEnabled {
			let shareLogsButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(mailLogs))
			navigationItem.rightBarButtonItem = shareLogsButton
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "SettingsView"])
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if availableUpdateZendDisk {
			getZendDeskUnReadTicket()
		}
		NotificationCenter.default.addObserver(self, selector: #selector(didUpdateFeedBackCell), name: .didReceiveZendDeskNotification, object: nil)
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	@objc func didUpdateFeedBackCell() {
		let indexPathForFeedback = IndexPath(row: 3, section: 0)
		guard let identifier = dataSource.itemIdentifier(for: indexPathForFeedback) else {
			return
		}
		var newSnapShot = dataSource.snapshot()
		newSnapShot.reloadItems([identifier])
		dataSource.apply(newSnapShot)
	}

	func getZendDeskUnReadTicket() {
		ZDKRequestProvider().getUpdatesForDevice { [unowned self] in
			if let updates = $0, updates.hasUpdatedRequests() {
				updateBadges(count: updates.totalUpdates)
			} else {
				updateBadges(count: 0)
			}
		}
	}

	func updateBadges(count: Int) {
		UserDefaults.zendeskChatNotificationCount = count
		AppDelegate.mainCoordinator?.updateZendeskBadges(count: count)
		AppDelegate.setAppIconBadge()
		didUpdateFeedBackCell()
	}
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 1 {
			return
		}
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
			showConnectedDevices()
		case .notifications:
			showNotifications()
		case .systemAuthorization:
			showSystemAuthorization()
		case .feedback:
			availableUpdateZendDisk = true
			showFeedback()
		case .privacyPolicy:
			showPrivacyPolicy()
		case .termsOfService:
			showTermsOfService()
		case .support:
			showSupport()
		case .troubleShoot:
			showHelpCenter()
		case .providers:
			showOrganizations()
		case .logging:
			showLogging()
		}
	}

	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		if section == 0 {
			let footerView = settingsFooterView
			settingsFooterView.delegate = self
			return footerView
		} else {
			let footerView = UIView()
			footerView.backgroundColor = .clear
			return footerView
		}
	}

	func showAccountDetails() {
		let profileEntryViewController = ProfileEntryViewController()
		profileEntryViewController.controllerViewMode = .settings
		profileEntryViewController.doneButtonTitle = NSLocalizedString("SAVE", comment: "Save")
		profileEntryViewController.patient = careManager.patient
		profileEntryViewController.hidesBottomBarWhenPushed = true
		profileEntryViewController.doneAction = { [weak self] in
			guard let strongSelf = self else {
				return
			}
			var alliePatient = strongSelf.careManager.patient ?? CHPatient(id: strongSelf.keychain.userIdentifier ?? "", name: PersonNameComponents())
			alliePatient.name = profileEntryViewController.name
			alliePatient.profile.email = profileEntryViewController.emailTextField.text
			alliePatient.sex = profileEntryViewController.sex
			alliePatient.updatedDate = Date()
			alliePatient.birthday = profileEntryViewController.dateOfBirth
			alliePatient.profile.weightInPounds = profileEntryViewController.weightInPounds
			alliePatient.profile.heightInInches = profileEntryViewController.heightInInches
			strongSelf.hud.show(in: strongSelf.view)
			strongSelf.networkAPI.post(patient: alliePatient)
				.sinkOnMain(receiveCompletion: { result in
					if case .failure(let error) = result {
						ALog.error("\(error.localizedDescription)")
						let okAction = AlertHelper.AlertAction(withTitle: String.ok)
						AlertHelper.showAlert(title: String.error, detailText: error.localizedDescription, actions: [okAction], from: strongSelf.tabBarController)
					}
					strongSelf.hud.dismiss()
					strongSelf.navigationController?.popViewController(animated: true)
				}, receiveValue: { [weak self] carePlanResponse in
					if let patient = carePlanResponse.patients.first {
						self?.careManager.patient = patient
						self?.keychain.userEmail = patient.profile.email
					}
				}).store(in: &strongSelf.cancellables)
		}
		navigationController?.show(profileEntryViewController, sender: self)
	}

	func showConnectedDevices() {
		let viewController = ConnectedDevicesViewController(style: .plain)
		viewController.hidesBottomBarWhenPushed = true
		navigationController?.show(viewController, sender: self)
	}

	func showNotifications() {
		let notificationSettingsController = NotificationSettingsController()
		notificationSettingsController.hidesBottomBarWhenPushed = true
		navigationController?.show(notificationSettingsController, sender: self)
	}

	func showSystemAuthorization() {
		if let url = URL(string: UIApplication.openSettingsURLString) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}

	func showFeedback() {
		let requestListController = RequestUi.buildRequestList(with: [])
		requestListController.hidesBottomBarWhenPushed = true
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
			let supportEngine = try SupportEngine.engine()
			let viewController = try Messaging.instance.buildUI(engines: [supportEngine], configs: [messagingConfiguration])
			viewController.hidesBottomBarWhenPushed = true
			navigationController?.show(viewController, sender: self)
			AppDelegate.mainCoordinator?.updateZendeskBadges(count: 0)
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
		guard let url = URL(string: AppConfig.privacyPolicyURL) else {
			return
		}
		let safariViewController = SFSafariViewController(url: url)
		safariViewController.delegate = self
		navigationController?.showDetailViewController(safariViewController, sender: self)
	}

	func showTermsOfService() {
		guard let url = URL(string: AppConfig.termsOfServiceURL) else {
			return
		}
		let safariViewController = SFSafariViewController(url: url)
		safariViewController.delegate = self
		navigationController?.showDetailViewController(safariViewController, sender: self)
	}

	func showOrganizations() {
		let selectProviderController = SelectProviderViewController(collectionViewLayout: SelectProviderViewController.layout)
		selectProviderController.isModel = false
		selectProviderController.hidesBottomBarWhenPushed = true
		navigationController?.show(selectProviderController, sender: self)
	}

	func showLogging() {
		let viewController = FileLoggingViewController()
		viewController.title = SettingsType.logging.title
		viewController.hidesBottomBarWhenPushed = true
		navigationController?.show(viewController, sender: self)
	}

	@IBAction func mailLogs() {
		guard let url = LoggingManager.fileLogURL, let data = try? Data(contentsOf: url, options: .mappedIfSafe) else {
			return
		}
		let mailComposer = MFMailComposeViewController()
		mailComposer.mailComposeDelegate = self
		mailComposer.setSubject("Allie Logs")
		mailComposer.setMessageBody("Attched Logs", isHTML: false)
		mailComposer.addAttachmentData(data, mimeType: "text/plain", fileName: "Allie.log")
		mailComposer.hidesBottomBarWhenPushed = true
		navigationController?.show(mailComposer, sender: self)
	}
}

extension SettingsViewController: SettingsFooterViewDelegate {
	func settingsFooterViewDidTapLogout(_ view: SettingsFooterView) {
		NotificationCenter.default.post(name: .applicationDidLogout, object: nil)
	}

	func settingsFooterViewDidTapDelete(_ view: SettingsFooterView) {
		let title = NSLocalizedString("DELETE_ACCOUNT", comment: "Delete Account")
		let message = NSLocalizedString("DELETE_ACCOUNT.message", comment: "Deleting your account is permanent and will remove all content. Are you sure you want to delete your account?")
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .cancel) { _ in
		}
		alertController.addAction(cancelAction)
		let deleteAction = UIAlertAction(title: NSLocalizedString("DELETE", comment: "Delete"), style: .destructive) { [weak self] _ in
			self?.deleteUser()
		}
		alertController.addAction(deleteAction)
		tabBarController?.present(alertController, animated: true, completion: nil)
	}

	func deleteUser() {
		guard let currentUser = Auth.auth().currentUser else {
			return
		}

		hud.textLabel.text = NSLocalizedString("DELETING_ACCOUNT", comment: "Deleteing Account")
		hud.detailTextLabel.text = nil

		hud.show(in: tabBarController?.view ?? navigationController?.view ?? view)
		currentUser.delete { [weak self] error in
			DispatchQueue.main.async {
				self?.hud.dismiss()
				if let error = error {
					ALog.error("Unable to delete account \(error.localizedDescription)")
					let title = NSLocalizedString("ACCOUNT_DELETION_ERROR", comment: "Account Deletion Error")
					let message = NSLocalizedString("ACCOUNT_DELETION_ERROR.message", comment: "Please try to Log Out and Log In again in order to Delete your account")
					let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
					let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) { _ in
					}
					controller.addAction(okAction)
					self?.navigationController?.showDetailViewController(controller, sender: self)
				} else {
					NotificationCenter.default.post(name: .applicationDidLogout, object: nil)
				}
			}
		}
	}
}

extension SettingsViewController: SFSafariViewControllerDelegate {
	func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true, completion: nil)
		if error == nil {
			if let fileURL = LoggingManager.fileLogURL {
				try? Data().write(to: fileURL, options: .noFileProtection)
			}
		}
	}
}

extension UITableViewCell {
	func setTableViewCellBadge(badgeCount: Int) {
		let size: CGFloat = 26
		let digits = CGFloat("\(badgeCount)".count)
		let width = max(size, 0.7 * size * digits)
		let badgeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: size))
		badgeLabel.text = "\(badgeCount)"
		badgeLabel.layer.cornerRadius = size / 2.0
		badgeLabel.layer.masksToBounds = true
		badgeLabel.textAlignment = .center
		badgeLabel.backgroundColor = .red
		badgeLabel.textColor = .white
		accessoryView = badgeLabel
	}
}
