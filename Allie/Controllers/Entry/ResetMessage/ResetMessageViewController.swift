//
//  ResetMessageViewController.swift
//  Allie

import BonMot
import UIKit

class ResetMessageViewController: BaseViewController {
	var backToSignInAction: Coordinator.ActionHandler?

	@IBOutlet var resetMesasageLabel: UILabel!
	@IBOutlet var backButton: UIButton!

	override func setupView() {
		super.setupView()
		title = Str.signup
		title = Str.resetPassword
		resetMesasageLabel.numberOfLines = 0
		resetMesasageLabel.attributedText = Str.longResetMessage.with(style: .regular17, andColor: .lightGray, andLetterSpacing: -0.408)
		let back = UILabel()
		back.attributedText = Str.backToSignIn.with(style: .semibold17, andColor: .black, andLetterSpacing: -0.408)
		backButton.setAttributedTitle(back.attributedText, for: .normal)
	}

	@IBAction func backToSignInBtnTapped(_ sender: Any) {
		backToSignInAction?()
	}
}
