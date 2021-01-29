//
//  SettingsFooterView.swift
//  Alfred
//

import UIKit

protocol SettingsFooterViewDelegate: AnyObject {
	func didTapLogout()
}

class SettingsFooterView: UIView {
	@IBOutlet var contentView: UIView!

	// MARK: - IBOutlets

	@IBOutlet var appVersionLbl: UILabel!
	@IBOutlet var logOutBtn: BottomButton!

	weak var delegate: SettingsFooterViewDelegate?

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	convenience init(viewHeight: CGFloat) {
		self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: viewHeight))
		commonInit()
	}

	func commonInit() {
		Bundle.main.loadNibNamed(Self.nibName, owner: self, options: nil)
		contentView.fixInView(self)
		setup()
	}

	private func localize() {
		logOutBtn.setAttributedTitle(Str.logout.uppercased().with(style: .semibold17, andColor: .white), for: .normal)
		if let version = Bundle.main.ch_appVersion {
			appVersionLbl.attributedText = Str.version(version).with(style: .regular17, andColor: UIColor.lightGrey, andLetterSpacing: -0.41)
		}
	}

	func setup() {
		localize()
		logOutBtn.setupButton()
	}

	@IBAction func logoutAction(_ sender: Any) {
		delegate?.didTapLogout()
	}
}
