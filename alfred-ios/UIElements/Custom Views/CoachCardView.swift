//
//  CoachCardView.swift
//  alfred-ios
//

import Foundation
import UIKit

protocol CoachCardViewDelegate: AnyObject {
	func actionBtnTapped(previewTitle: String?, title: String?, text: String?, icon: IconType?)
	func closeBtnTapped(uuid: String)
}

class CoachCardView: UIView {
	@IBOutlet var contentView: UIView!

	let kCONTENT_XIB_NAME = "CoachCardView"

	// MARK: - IBOutlets

	@IBOutlet var view: UIView!
	@IBOutlet var titleLbl: UILabel!
	@IBOutlet var descLbl: UILabel!
	@IBOutlet var closeBtn: UIButton!
	@IBOutlet var actionBtn: UIButton!
	@IBOutlet var cardView: UIView!

	// MARK: - Vars

	var backgroundClr = UIColor.white {
		didSet {
			view.backgroundColor = backgroundClr
		}
	}

	var previewTitle: String? {
		didSet {
			if let previewTitle = previewTitle {
				titleLbl.attributedText = previewTitle.with(style: .bold17, andColor: .white, andLetterSpacing: -0.32)
			}
		}
	}

	var previewText: String? {
		didSet {
			if let previewText = previewText {
				descLbl.attributedText = previewText.with(style: .regular17, andColor: .white, andLetterSpacing: -0.32)
			}
		}
	}

	var buttonText: String? {
		didSet {
			if let buttonText = buttonText {
				actionBtn.setAttributedTitle(buttonText.with(style: .bold17, andColor: .white, andLetterSpacing: -0.32), for: .normal)
			}
		}
	}

	weak var delegate: CoachCardViewDelegate?
	var card: NotificationCardData?

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	convenience init(card: NotificationCardData) {
		self.init(frame: CGRect.zero)
		self.card = card
		commonInit()
	}

	func commonInit() {
		Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
		contentView.fixInView(self)
		setup()
	}

	func setup() {
		guard let card = card else { return }

		previewTitle = card.previewTitle
		previewText = card.previewText
		if let title = card.title {
			buttonText = title.uppercased()
			let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
			cardView.addGestureRecognizer(tap)
		} else {
			actionBtn.removeFromSuperview()
		}

		if let color = UIColor(hex: card.backgroundColor) {
			backgroundClr = color
		}
	}

	@IBAction func actionBtnTapped(_ sender: Any) {
		guard let card = card else { return }
		delegate?.actionBtnTapped(previewTitle: card.previewTitle, title: card.title, text: card.text, icon: card.icon)
	}

	@IBAction func closeBtnTapped(_ sender: Any) {
		guard let id = card?.uuid else { return }
		delegate?.closeBtnTapped(uuid: id)
	}

	@objc func cardTapped() {
		guard let card = card else { return }
		delegate?.actionBtnTapped(previewTitle: card.previewTitle, title: card.title, text: card.text, icon: card.icon)
	}
}
