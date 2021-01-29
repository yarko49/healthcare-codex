import FirebaseAuth
import MessageUI
import UIKit

class SettingsCoordinator: NSObject, Coordinator {
	internal var navigationController: UINavigationController? = {
		UINavigationController(nibName: nil, bundle: nil)
	}()

	internal var childCoordinators: [CoordinatorKey: Coordinator]
	internal weak var parentCoordinator: MainAppCoordinator?

	var rootViewController: UIViewController? {
		navigationController
	}

	init(with parent: MainAppCoordinator?) {
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
		settingsViewController.accountDetailsAction = { [weak self] in
			self?.goToAccountDetails()
		}
		settingsViewController.myDevicesAction = { [weak self] in
			self?.goToMyDevices()
		}
		settingsViewController.notificationsAction = { [weak self] in
			self?.goToNotifications()
		}
		settingsViewController.systemAuthorizationAction = { [weak self] in
			self?.goToSystemAuthorization()
		}
		settingsViewController.feedbackAction = { [weak self] in
			self?.goToFeedback()
		}
		settingsViewController.privacyPolicyAction = { [weak self] in
			self?.goToPrivacyPolicy()
		}
		settingsViewController.termsOfServiceAction = { [weak self] in
			self?.goToTermsOfService()
		}
		settingsViewController.logoutAction = { [weak self] in
			self?.logout()
		}
		navigate(to: settingsViewController, with: .pushFullScreen)
	}

	internal func goToAccountDetails() {
		let accountDetailsViewController = AccountDetailsViewController()

		accountDetailsViewController.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		accountDetailsViewController.resetPasswordAction = { [weak self] in
			self?.goToPasswordReset()
		}

		navigate(to: accountDetailsViewController, with: .pushFullScreen)
	}

	internal func goToPasswordReset() {
		let accountResetPasswordViewController = AccountResetPasswordViewController()

		accountResetPasswordViewController.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}
		accountResetPasswordViewController.sendEmailAction = { [weak self, weak accountResetPasswordViewController] email in
			self?.resetPassword(accountResetPasswordViewController: accountResetPasswordViewController, email: email)
		}

		navigate(to: accountResetPasswordViewController, with: .pushFullScreen)
	}

	internal func resetPassword(accountResetPasswordViewController: AccountResetPasswordViewController?, email: String?) {
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

	internal func goToMyDevices() {
		let devicesViewController = MyDevicesViewController()

		devicesViewController.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		devicesViewController.profileRequestAction = { [weak self] in
			let profile = Profile(dataContext: DataContext.shared)
			self?.profileRequest(profile: profile)
		}

		navigate(to: devicesViewController, with: .pushFullScreen)
	}

	internal func profileRequest(profile: Profile) {
		showHUD()
		AlfredClient.client.postProfile(profile: profile) { [weak self] result in
			self?.hideHUD()
			switch result {
			case .failure(let error):
				ALog.error("request failed", error: error)
				AlertHelper.showAlert(title: Str.error, detailText: Str.createProfileFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
			case .success(let resource):
				ALog.info("OK STATUS FOR PROFILE: 200 \(String(describing: resource))")
				self?.navigationController?.popViewController(animated: true)
			}
		}
	}

	internal func goToNotifications() {
		let myNotificationsViewController = MyNotificationsViewController()
		myNotificationsViewController.backBtnAction = { [weak self] in
			let profile = Profile(dataContext: DataContext.shared)
			self?.profileRequest(profile: profile)
		}
		navigate(to: myNotificationsViewController, with: .pushFullScreen)
	}

	internal func goToSystemAuthorization() {
		// TODO: I think we can only go up to Settings
		if let url = URL(string: UIApplication.openSettingsURLString) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}

	internal func goToFeedback() {
		guard MFMailComposeViewController.canSendMail() else {
			showMailSetupAlert()
			return
		}

		let controller = MFMailComposeViewController()
		let subject = NSLocalizedString("FEEDBACK_SUBJECT", comment: "Feedback")
		controller.setSubject(subject)
		let toEmail = "" // DataContext.shared.remoteConfigManager.feedbackEmail
		controller.setToRecipients([toEmail])
		controller.mailComposeDelegate = self
		navigate(to: controller, with: .present)
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

	internal func goToPrivacyPolicy() {
		let privacyPolicyViewController = PrivacyPolicyViewController()

		privacyPolicyViewController.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		navigate(to: privacyPolicyViewController, with: .pushFullScreen)
	}

	internal func goToTermsOfService() {
		let termsOfServiceViewController = TermsOfServiceViewController()

		termsOfServiceViewController.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		navigate(to: termsOfServiceViewController, with: .pushFullScreen)
	}

	private func logout() {
		let firebaseAuth = Auth.auth()
		do {
			try firebaseAuth.signOut()
			parentCoordinator?.logout()
			DataContext.shared.clearAll()
		} catch let signOutError as NSError {
			ALog.error("Error signing out:", error: signOutError)
		}
	}

	internal func stop() {
		rootViewController?.dismiss(animated: true, completion: { [weak self] in
			guard let self = self else { return }
			self.parentCoordinator?.removeChild(.settingsCoordinator)
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
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		if viewController is SettingsViewController {
			if viewController.navigationItem.leftBarButtonItem == nil {
				let backBtn = UIBarButtonItem(image: UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain, target: self, action: #selector(backAction))
				backBtn.tintColor = .black
				viewController.navigationItem.setLeftBarButton(backBtn, animated: true)
			}
		}
	}
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
