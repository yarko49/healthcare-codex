//
//  ResetMessageViewController.swift
//  Allie

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
		var attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17.0, weight: .regular), .foregroundColor: UIColor.lightGray, .kern: NSNumber(-0.408)]
		resetMesasageLabel.attributedText = NSAttributedString(string: .longResetMessage, attributes: attributes)
		let back = UILabel()
		attributes[.font] = UIColor.black
		back.attributedText = NSAttributedString(string: .backToSignIn, attributes: attributes)
		backButton.setAttributedTitle(back.attributedText, for: .normal)
	}

	@IBAction func backToSignInBtnTapped(_ sender: Any) {
		backToSignInAction?()
	}
}
