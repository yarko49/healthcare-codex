import FirebaseAuth
import UIKit

class SettingsCoordinator: NSObject, Coordinator {
	internal var navigationController: UINavigationController?
	internal var childCoordinators: [CoordinatorKey: Coordinator]
	internal weak var parentCoordinator: MainAppCoordinator?

	var rootViewController: UIViewController? {
		return navigationController
	}

	init(with parent: MainAppCoordinator?) {
		self.navigationController = SettingsNC()
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

	internal func goToSettings() {
		let settingsVC = SettingsVC()
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
		let accountDetailsVC = AccountDetailsVC()

		accountDetailsVC.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		accountDetailsVC.resetPasswordAction = { [weak self] in
			self?.goToPasswordReset()
		}

		navigate(to: accountDetailsVC, with: .pushFullScreen)
	}

	internal func goToPasswordReset() {
		let accountResetPasswordVC = AccountResetPasswordVC()

		accountResetPasswordVC.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}
		accountResetPasswordVC.sendEmailAction = { [weak self, weak accountResetPasswordVC] email in
			self?.resetPassword(accountResetPasswordVC: accountResetPasswordVC, email: email)
		}

		navigate(to: accountResetPasswordVC, with: .pushFullScreen)
	}

	internal func resetPassword(accountResetPasswordVC: AccountResetPasswordVC?, email: String?) {
		AlertHelper.showSendLoader()
		Auth.auth().sendPasswordReset(withEmail: email ?? "") { error in
			if error != nil {
				print(error ?? "")
				AlertHelper.showAlert(title: Str.error, detailText: Str.invalidEmail, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
			} else {
				AlertHelper.hideLoader()
				accountResetPasswordVC?.showCompletionMessage()
			}
		}
	}

	internal func goToMyDevices() {
		let devicesVC = MyDevicesVC()

		devicesVC.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		devicesVC.profileRequestAction = { [weak self] in
			let profile = DataContext.shared.createProfileModel()
			self?.profileRequest(profile: profile)
		}

		navigate(to: devicesVC, with: .pushFullScreen)
	}

	internal func profileRequest(profile: ProfileModel) {
		DataContext.shared.postProfile(profile: profile) { [weak self] success in
			if success {
				print("OK STATUS FOR PROFILE: 200", DataContext.shared.signUpCompleted)
				AlertHelper.hideLoader()
				self?.navigationController?.popViewController(animated: true)
			} else {
				print("request failed")
				AlertHelper.showAlert(title: Str.error, detailText: Str.createProfileFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
			}
		}
	}

	internal func goToNotifications() {
		let myNotificationsVC = MyNotificationsVC()

		myNotificationsVC.backBtnAction = { [weak self] in
			let profile = DataContext.shared.createProfileModel()
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

	internal func goToFeedback() {}

	internal func goToPrivacyPolicy() {
		let privacyPolicyVC = PrivacyPolicyVC()

		privacyPolicyVC.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		navigate(to: privacyPolicyVC, with: .pushFullScreen)
	}

	internal func goToTermsOfService() {
		let termsOfServiceVC = TermsOfServiceVC()

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
		} catch let signOutError as NSError {
			print("Error signing out: %@", signOutError)
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
		if viewController is SettingsVC {
			if viewController.navigationItem.leftBarButtonItem == nil {
				let backBtn = UIBarButtonItem(image: UIImage(named: "back")?.withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain, target: self, action: #selector(backAction))
				backBtn.tintColor = .black
				viewController.navigationItem.setLeftBarButton(backBtn, animated: true)
			}
		}
	}
}

extension SettingsCoordinator: UIAdaptivePresentationControllerDelegate {
	func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
		print("dismiss")
		stop()
	}
}
