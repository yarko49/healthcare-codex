import JGProgressHUD
import UIKit

class AlertHelper {
	struct AlertAction {
		let title: String
		let style: UIAlertAction.Style
		let action: (() -> Void)?

		init(withTitle title: String, style: UIAlertAction.Style = .default, andAction action: (() -> Void)? = nil) {
			self.title = title
			self.style = style
			self.action = action
		}
	}

	static var progressHUD: JGProgressHUD {
		let hud = JGProgressHUD(style: .dark)
		hud.interactionType = .blockAllTouches
		hud.vibrancyEnabled = true
		return hud
	}

	static func showAlert(title: String?, detailText: String?, actions: [AlertAction], style: UIAlertController.Style = .alert, fillProportionally: Bool = false, from viewController: UIViewController? = UIApplication.shared.windows.first?.visibleViewController()) {
		let alertController = UIAlertController(title: title, message: detailText, preferredStyle: style)
		actions.forEach { alertAction in
			let action = UIAlertAction(title: alertAction.title, style: alertAction.style, handler: { _ in
				alertAction.action?()
			})
			alertController.addAction(action)
		}
		present(alertController, from: viewController)
	}

	static func present(_ modalViewController: UIViewController?, from viewController: UIViewController? = UIApplication.shared.windows.first?.visibleViewController()) {
		guard let modalViewController = modalViewController else { return }
		modalViewController.modalTransitionStyle = .crossDissolve
		modalViewController.modalPresentationStyle = .overFullScreen
		viewController?.present(modalViewController, animated: true, completion: nil)
	}
}
