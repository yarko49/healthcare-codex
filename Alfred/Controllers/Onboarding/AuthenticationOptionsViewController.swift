//
//  AuthenticationOptionsViewController.swift
//  Alfred
//
//  Created by Waqar Malik on 1/8/21.
//

import AuthenticationServices
import UIKit

enum AuthenticationProviderType: Hashable, CaseIterable {
	case apple
	case google
	case email
}

protocol AuthenticationOptionsViewControllerDelegate: AnyObject {
	func authenticationOptionsViewController(_ controller: AuthenticationOptionsViewController, didSelectProvider provider: AuthenticationProviderType)
}

class AuthenticationOptionsViewController: BaseViewController {
	enum Constants {
		static let slideUpAnimationDuration: TimeInterval = 0.25
		static let slideOutAnimationDuration: TimeInterval = 0.25
		static let slideSnapAnimationDuration: TimeInterval = 0.15
		static let panMinimumYTranslation: CGFloat = 150.0
	}

	var authorizationFlowType: AuthorizationFlowType = .signUp
	weak var delegate: AuthenticationOptionsViewControllerDelegate?
	private var bottonYConstraint: NSLayoutConstraint!

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .clear
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(backgroundView)
		NSLayoutConstraint.activate([backgroundView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 0.0),
		                             backgroundView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 0.0),
		                             view.trailingAnchor.constraint(equalToSystemSpacingAfter: backgroundView.trailingAnchor, multiplier: 0.0),
		                             view.bottomAnchor.constraint(equalToSystemSpacingBelow: backgroundView.bottomAnchor, multiplier: 0.0)])

		contentView.delegate = self
		contentView.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.addSubview(contentView)
		bottonYConstraint = backgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AuthenticationOptionsView.height)
		NSLayoutConstraint.activate([contentView.leadingAnchor.constraint(equalToSystemSpacingAfter: backgroundView.leadingAnchor, multiplier: 0.0),
		                             contentView.heightAnchor.constraint(equalToConstant: AuthenticationOptionsView.height),
		                             backgroundView.trailingAnchor.constraint(equalToSystemSpacingAfter: contentView.trailingAnchor, multiplier: 0.0),
		                             bottonYConstraint])

		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePane(_:)))
		backgroundView.addGestureRecognizer(panGesture)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		UIView.animate(withDuration: Constants.slideUpAnimationDuration) { [weak self] in
			self?.bottonYConstraint.constant = 0.0
			self?.view.layoutIfNeeded()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if animated {
			UIView.animate(withDuration: Constants.slideOutAnimationDuration) { [weak self] in
				guard let self = self else {
					return
				}
				self.backgroundView.alpha = 0.0
				var frame = self.view.frame
				frame.origin.y = frame.height
				self.backgroundView.frame = frame
			}
		}
	}

	private let backgroundView: UIView = {
		let view = UIView(frame: .zero)
		view.backgroundColor = UIColor(white: 0.0, alpha: 0.50)
		return view
	}()

	private lazy var contentView: AuthenticationOptionsView = {
		let view = AuthenticationOptionsView(frame: .zero, authorizationFlowType: self.authorizationFlowType)
		return view
	}()

	@IBAction private func handlePane(_ gesture: UIPanGestureRecognizer) {
		let translation = gesture.translation(in: view)
		switch gesture.state {
		case .began, .cancelled, .failed:
			break
		case .changed:
			guard let gestureView = gesture.view, translation.y > 0 else {
				return
			}
			gestureView.center = CGPoint(x: gestureView.center.x, y: gestureView.center.y + translation.y)

			gesture.setTranslation(.zero, in: view)
		case .ended:
			guard let gestureView = gesture.view else {
				return
			}

			if gestureView.center.y > view.center.y + Constants.panMinimumYTranslation {
				dismiss(animated: true, completion: nil)
			} else {
				UIView.animate(withDuration: Constants.slideSnapAnimationDuration) {
					gestureView.center = self.view.center
				} completion: { finsihed in
					if finsihed {
						gesture.setTranslation(.zero, in: self.view)
					}
				}
			}
		default:
			break
		}
	}
}

extension AuthenticationOptionsViewController: AuthenticationOptionsViewDelegate {
	func authenticationOptionsView(_ view: AuthenticationOptionsView, didSelectProvider provider: AuthenticationProviderType) {
		dismiss(animated: true) { [weak self] in
			guard let self = self else {
				return
			}
			self.delegate?.authenticationOptionsViewController(self, didSelectProvider: provider)
		}
	}

	func authenticationOptionsViewDidCancel(_ view: AuthenticationOptionsView) {
		dismiss(animated: true, completion: nil)
	}
}
