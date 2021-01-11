//
//  HUDViewController.swift
//  Alfred
//
//  Created by Waqar Malik on 1/9/21.
//

import UIKit

class HUDView: UIViewController {
	var dismissHandler: (() -> Void)?

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor(white: 0.0, alpha: 0.35)
		backgroundBlurView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(backgroundBlurView)
		NSLayoutConstraint.activate([backgroundBlurView.widthAnchor.constraint(equalToConstant: 100.0),
		                             backgroundBlurView.heightAnchor.constraint(equalToConstant: 100.0),
		                             backgroundBlurView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
		                             backgroundBlurView.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(activityIndicator)
		NSLayoutConstraint.activate([activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		                             activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)])

		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(titleLabel)
		NSLayoutConstraint.activate([titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 3.0),
		                             backgroundBlurView.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 2.0)])
		subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(subtitleLabel)
		NSLayoutConstraint.activate([subtitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: subtitleLabel.trailingAnchor, multiplier: 3.0),
		                             subtitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: backgroundBlurView.bottomAnchor, multiplier: 2.0)])
	}

	private let backgroundBlurView: UIVisualEffectView = {
		let effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
		let view = UIVisualEffectView(effect: effect)
		view.clipsToBounds = true
		view.layer.cornerRadius = 15.0
		view.layer.cornerCurve = .continuous
		return view
	}()

	let titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textColor = .darkText
		label.font = UIFont.preferredFont(forTextStyle: .title3)
		label.textAlignment = .center
		label.numberOfLines = 2
		return label
	}()

	private let activityIndicator: UIActivityIndicatorView = {
		let view = UIActivityIndicatorView(style: .large)
		view.hidesWhenStopped = true
		view.startAnimating()
		view.color = .enterGrey
		return view
	}()

	let subtitleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textColor = .darkText
		label.font = UIFont.preferredFont(forTextStyle: .body)
		label.textAlignment = .center
		label.numberOfLines = 3
		return label
	}()

	private(set) static var presentedHUD: HUDView?

	@discardableResult
	class func show(presentingViewController: UIViewController?, title: String? = nil, subtitle: String? = nil, animated: Bool = true) -> HUDView? {
		guard presentedHUD == nil else {
			return nil
		}
		let viewController = HUDView()
		viewController.titleLabel.text = title
		viewController.subtitleLabel.text = subtitle
		viewController.modalPresentationStyle = .custom
		viewController.modalTransitionStyle = .crossDissolve
		presentingViewController?.present(viewController, animated: animated) {}
		presentedHUD = viewController
		return viewController
	}

	static func hide(animated: Bool = true) {
		presentedHUD?.dismiss(animated: animated) {
			self.presentedHUD?.dismissHandler?()
			self.presentedHUD = nil
		}
	}
}
