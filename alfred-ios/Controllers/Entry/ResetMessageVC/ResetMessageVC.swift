//
//  ResetMessageVC.swift
//  alfred-ios

import UIKit

class ResetMessageVC: BaseVC {
	var backBtnAction: (() -> Void)?
	var backToSignInAction: (() -> Void)?

	@IBOutlet var resetMesasageLbl: UILabel!
	@IBOutlet var backBtn: UIButton!

	override func setupView() {
		super.setupView()
		let navBar = navigationController?.navigationBar
		navBar?.setBackgroundImage(UIImage(), for: .default)
		navBar?.shadowImage = UIImage()
		navBar?.isHidden = false
		navBar?.isTranslucent = false
		title = Str.signup
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backBtnTapped))
		navigationItem.leftBarButtonItem?.tintColor = UIColor.black
		navBar?.layoutIfNeeded()
		title = Str.resetPassword
		resetMesasageLbl.numberOfLines = 0
		resetMesasageLbl.attributedText = Str.longResetMessage.with(style: .regular17, andColor: .lightGray, andLetterSpacing: -0.408)
		let back = UILabel()
		back.attributedText = Str.backToSignIn.with(style: .semibold17, andColor: .black, andLetterSpacing: -0.408)
		backBtn.setAttributedTitle(back.attributedText, for: .normal)
	}

	@IBAction func backToSignInBtnTapped(_ sender: Any) {
		backToSignInAction?()
	}

	@objc func backBtnTapped() {
		backBtnAction?()
	}
}
