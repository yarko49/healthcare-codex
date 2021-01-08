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
		let settingsVC = SettingsViewController()
		settingsVC.accountDetailsAction = { [weak self] in
			self?.goToAccountDetails()
		}
		settingsVC.myDevicesAction = { [weak self] in
			self?.goToMyDevices()
		}
		settingsVC.notificationsAction = { [weak self] in
			self?.goToNotifications()
		}
		settingsVC.systemAuthorizationAction = { [weak self] in
			self?.goToSystemAuthorization()
		}
		settingsVC.feedbackAction = { [weak self] in
			self?.goToFeedback()
		}
		settingsVC.privacyPolicyAction = { [weak self] in
			self?.goToPrivacyPolicy()
		}
		settingsVC.termsOfServiceAction = { [weak self] in
			self?.goToTermsOfService()
		}
		settingsVC.logoutAction = { [weak self] in
			self?.logout()
		}
		navigate(to: settingsVC, with: .pushFullScreen)
	}

	internal func goToAccountDetails() {
		let accountDetailsVC = AccountDetailsViewController()

		accountDetailsVC.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		accountDetailsVC.resetPasswordAction = { [weak self] in
			self?.goToPasswordReset()
		}

		navigate(to: accountDetailsVC, with: .pushFullScreen)
	}

	internal func goToPasswordReset() {
		let accountResetPasswordVC = AccountResetPasswordViewController()

		accountResetPasswordVC.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}
		accountResetPasswordVC.sendEmailAction = { [weak self, weak accountResetPasswordVC] email in
			self?.resetPassword(accountResetPasswordVC: accountResetPasswordVC, email: email)
		}

		navigate(to: accountResetPasswordVC, with: .pushFullScreen)
	}

	internal func resetPassword(accountResetPasswordVC: AccountResetPasswordViewController?, email: String?) {
		showHUD()
		Auth.auth().sendPasswordReset(withEmail: email ?? "") { [weak self] error in
			self?.hideHUD()
			if error != nil {
				ALog.error("\(error?.localizedDescription ?? "")")
				AlertHelper.showAlert(title: Str.error, detailText: Str.invalidEmail, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
			} else {
				accountResetPasswordVC?.showCompletionMessage()
			}
		}
	}

	internal func goToMyDevices() {
		let devicesVC = MyDevicesViewController()

		devicesVC.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		devicesVC.profileRequestAction = { [weak self] in
			let profile = DataContext.shared.createProfile()
			self?.profileRequest(profile: profile)
		}

		navigate(to: devicesVC, with: .pushFullScreen)
	}

	internal func profileRequest(profile: Profile) {
		AlfredClient.client.postProfile(profile: profile) { [weak self] result in
			self?.hideHUD()
			switch result {
			case .failure(let error):
				ALog.error("request failed \(error.localizedDescription)")
				AlertHelper.showAlert(title: Str.error, detailText: Str.createProfileFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
			case .success(let resource):
				ALog.info("OK STATUS FOR PROFILE: 200 \(String(describing: resource))")
				self?.navigationController?.popViewController(animated: true)
			}
		}
	}

	internal func goToNotifications() {
		let myNotificationsVC = MyNotificationsViewController()
		myNotificationsVC.backBtnAction = { [weak self] in
			let profile = DataContext.shared.createProfile()
			self?.profileRequest(profile: profile)
		}
		navigate(to: myNotificationsVC, with: .pushFullScreen)
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
		let toEmail = DataContext.shared.remoteConfigManager.feedbackEmail
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
		let privacyPolicyVC = PrivacyPolicyViewController()

		privacyPolicyVC.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		navigate(to: privacyPolicyVC, with: .pushFullScreen)
	}

	internal func goToTermsOfService() {
		let termsOfServiceVC = TermsOfServiceViewController()

		termsOfServiceVC.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		navigate(to: termsOfServiceVC, with: .pushFullScreen)
	}

	private func logout() {
		let firebaseAuth = Auth.auth()
		do {
			try firebaseAuth.signOut()
			parentCoordinator?.logout()
			DataContext.shared.clearAll()
		} catch let signOutError as NSError {
			ALog.error("Error signing out: \(signOutError.localizedDescription)")
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
				let backBtn = UIBarButtonItem(image: UIImage(named: "back")?.withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain, target: self, action: #selector(backAction))
				backBtn.tintColor = .black
				viewController.navigationItem.setLeftBarButton(backBtn, animated: true)
			}
		}
	}
}

extension SettingsCoordinator: MFMailComposeViewControllerDelegate {
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		if let error = error {
			ALog.error("\(error.localizedDescription)")
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
