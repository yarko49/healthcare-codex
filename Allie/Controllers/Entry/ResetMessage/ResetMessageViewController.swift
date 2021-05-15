//
//  ResetMessageViewController.swift
//  Allie

import BonMot
import UIKit

class ResetMessageViewController: BaseViewController {
	var backToSignInAction: Coordinable.ActionHandler?

	@IBOutlet var resetMesasageLabel: UILabel!
	@IBOutlet var backButton: UIButton!

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "ResetMessageView"])
	}

	override func setupView() {
		super.setupView()
		title = String.signup
		title = String.resetPassword
		resetMesasageLabel.numberOfLines = 0
		resetMesasageLabel.attributedText = String.longResetMessage.with(style: .regular17, andColor: .lightGray, andLetterSpacing: -0.408)
		let back = UILabel()
		back.attributedText = String.backToSignIn.with(style: .semibold17, andColor: .black, andLetterSpacing: -0.408)
		backButton.setAttributedTitle(back.attributedText, for: .normal)
	}

	@IBAction func backToSignInBtnTapped(_ sender: Any) {
		backToSignInAction?()
	}
}
