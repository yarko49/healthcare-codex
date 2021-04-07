import AnswerBotSDK
import ChatSDK
import FirebaseAuth
import MessageUI
import MessagingSDK
import SafariServices
import SDKConfigurations
import SupportSDK
import UIKit

class SettingsCoordinator: NSObject, Coordinable {
	let type: CoordinatorType = .settingsCoordinator

	internal var navigationController: UINavigationController? = {
		UINavigationController(nibName: nil, bundle: nil)
	}()

	internal var childCoordinators: [CoordinatorType: Coordinable]
	internal weak var parentCoordinator: AppCoordinator?

	var rootViewController: UIViewController? {
		navigationController
	}

	init(with parent: AppCoordinator?) {
		self.parentCoordinator = parent
		self.childCoordinators = [:]
		super.init()
		navigationController?.delegate = self
	}

	internal func start() {
		goToSettings()
		if let nav = rootViewController {
			nav.presentationController?.delegate = self
			parentCoordinator?.navigate(to: nav, with: .present)
		}
	}

	func showHUD(animated: Bool = true) {
		parentCoordinator?.showHUD(animated: animated)
	}

	func hideHUD(animated: Bool = true) {
		parentCoordinator?.hideHUD(animated: animated)
	}

	internal func goToSettings() {
		let settingsViewController = SettingsViewController()

		settingsViewController.itemSelectionAction = { [weak self] item in
			switch item {
			case .accountDetails:
				self?.goToAccountDetails()
			case .myDevices:
				self?.goToMyDevices()
			case .notifications:
				self?.goToNotifications()
			case .systemAuthorization:
				self?.goToSystemAuthorization()
			case .feedback:
				self?.showFeedback()
			case .privacyPolicy:
				self?.gotoPrivacyPolicy()
			case .termsOfService:
				self?.gotoTermsOfService()
			case .support:
				self?.showSupport()
			case .troubleShoot:
				self?.showHelpCenter()
			}
		}

		settingsViewController.logoutAction = { [weak self] in
			self?.logout()
		}

		settingsViewController.didFinishAction = { [weak settingsViewController] in
			settingsViewController?.dismiss(animated: true, completion: nil)
		}

		navigate(to: settingsViewController, with: .pushFullScreen)
	}

	internal func goToAccountDetails() {
		let accountDetailsViewController = AccountDetailsViewController()

		accountDetailsViewController.resetPasswordAction = { [weak self] in
			self?.goToPasswordReset()
		}

		navigate(to: accountDetailsViewController, with: .pushFullScreen)
	}

	func goToPasswordReset() {
		let accountResetPasswordViewController = AccountResetPasswordViewController()

		accountResetPasswordViewController.sendEmailAction = { [weak self, weak accountResetPasswordViewController] email in
			self?.resetPassword(accountResetPasswordViewController: accountResetPasswordViewController, email: email)
		}

		navigate(to: accountResetPasswordViewController, with: .pushFullScreen)
	}

	func resetPassword(accountResetPasswordViewController: AccountResetPasswordViewController?, email: String?) {
		showHUD()
		Auth.auth().sendPasswordReset(withEmail: email ?? "") { [weak self] error in
			self?.hideHUD()
			if error != nil {
				ALog.error(error: error)
				AlertHelper.showAlert(title: Str.error, detailText: Str.invalidEmail, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
			} else {
				accountResetPasswordViewController?.showCompletionMessage()
			}
		}
	}

	func goToMyDevices() {
		let devicesViewController = DevicesSelectionViewController()
		devicesViewController.nextButtonAction = { [weak self] in
			self?.profileRequest()
		}

		navigate(to: devicesViewController, with: .pushFullScreen)
	}

	func profileRequest() {
		careManager.loadPatient { [weak self] result in
			switch result {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
			case .success(let patient):
				let alliePatient = AlliePatient(ockPatient: patient)
				APIClient.client.postPatient(patient: alliePatient) { result in
					ALog.info("\(result)")
				}
			}
		}
		navigationController?.popViewController(animated: true)
	}

	func goToNotifications() {
		let myNotificationsViewController = NotificationSettingsController()
		myNotificationsViewController.dismissAction = { [weak self] in
			self?.profileRequest()
		}
		navigate(to: myNotificationsViewController, with: .pushFullScreen)
	}

	internal func goToSystemAuthorization() {
		// TODO: I think we can only go up to Settings
		if let url = URL(string: UIApplication.openSettingsURLString) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}

	internal func showFeedback() {
		let config = RequestUiConfiguration()
		config.subject = "iOS Ticket"
		config.tags = ["ios", "mobile"]
		let requestListController = RequestUi.buildRequestList(with: [config])
		navigate(to: requestListController, with: .push)
	}

	internal func showHelpCenter() {
		guard let url = URL(string: "https://codexhealth.zendesk.com/hc/en-us") else {
			return
		}
		let safarViewController = SFSafariViewController(url: url)
		safarViewController.delegate = self
		navigate(to: safarViewController, with: .present)
	}

	internal func showSupport() {
		do {
			let messagingConfiguration = MessagingConfiguration()
			let answerBotEngine = try AnswerBotEngine.engine()
			let supportEngine = try SupportEngine.engine()
			let chatEngine = try ChatEngine.engine()
			let viewController = try Messaging.instance.buildUI(engines: [supportEngine, chatEngine, answerBotEngine], configs: [messagingConfiguration])
			navigate(to: viewController, with: .push)
		} catch {
			ALog.error("Unable to show support", error: error)
		}
	}

	internal func showMailSetupAlert() {
		let title = NSLocalizedString("NO_EMAIL_SETUP.title", comment: "Email Setup")
		let message = NSLocalizedString("NO_EMAIL_SETUP.message", comment: "Please setup default email!")
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let cancelTitle = NSLocalizedString("CANCEL", comment: "Cancel")
		let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { _ in
		}
		alertController.addAction(cancelAction)
		navigate(to: alertController, with: .present)
	}

	internal func gotoPrivacyPolicy() {
		let privacyPolicyViewController = HTMLViewerController()
		privacyPolicyViewController.title = Str.privacyPolicy
		navigate(to: privacyPolicyViewController, with: .pushFullScreen)
	}

	internal func gotoTermsOfService() {
		let termsOfServiceViewController = HTMLViewerController()
		termsOfServiceViewController.title = Str.privacyPolicy
		navigate(to: termsOfServiceViewController, with: .pushFullScreen)
	}

	private func logout() {
		parentCoordinator?.logout()
	}

	internal func stop() {
		rootViewController?.dismiss(animated: true, completion: { [weak self] in
			guard let strongSelf = self else { return }
			strongSelf.parentCoordinator?.removeCoordinator(ofType: .settingsCoordinator)
		})
	}

	deinit {
		navigationController?.viewControllers = []
		rootViewController?.dismiss(animated: true, completion: nil)
	}

	@objc internal func backAction() {
		stop()
	}
}

extension SettingsCoordinator: UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {}
}

extension SettingsCoordinator: MFMailComposeViewControllerDelegate {
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		if let error = error {
			ALog.error(error: error)
		}

		controller.dismiss(animated: true, completion: nil)
	}
}

extension SettingsCoordinator: UIAdaptivePresentationControllerDelegate {
	func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
		ALog.info("dismiss")
		stop()
	}
}

extension SettingsCoordinator: SFSafariViewControllerDelegate {}
