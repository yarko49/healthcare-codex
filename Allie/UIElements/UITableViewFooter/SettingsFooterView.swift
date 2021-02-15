//
//  SettingsFooterView.swift
//  Allie
//

import UIKit

protocol SettingsFooterViewDelegate: AnyObject {
	func settingsFooterViewDidTapLogout(_ view: SettingsFooterView)
}

class SettingsFooterView: UIView {
	@IBOutlet var contentView: UIView!

	// MARK: - IBOutlets

	@IBOutlet var appVersionLabel: UILabel!
	@IBOutlet var logOutButton: BottomButton!

	weak var delegate: SettingsFooterViewDelegate?

	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}

	func commonInit() {
		Bundle.main.loadNibNamed(Self.nibName, owner: self, options: nil)
		contentView.fixInView(self)
		setup()
	}

	private func localize() {
		logOutButton.setAttributedTitle(Str.logout.uppercased().with(style: .semibold17, andColor: .white), for: .normal)
		if let version = Bundle.main.ch_appVersion {
			appVersionLabel.attributedText = Str.version(version).with(style: .regular17, andColor: UIColor.lightGrey, andLetterSpacing: -0.41)
		}
	}

	func setup() {
		localize()
		logOutButton.setupButton()
	}

	@IBAction func logoutAction(_ sender: Any) {
		delegate?.settingsFooterViewDidTapLogout(self)
	}
}
