//
//  TroubleshootingVC.swift
//  alfred-ios
//

import Foundation
import UIKit

class TroubleshootingViewController: BaseViewController {
	// MARK: - Coordinator Actions

	// MARK: - Properties

	var previewTitle: String = ""
	var titleText: String = ""
	var text: String = ""

	// MARK: - IBOutlets

	@IBOutlet var iconIV: UIImageView!
	@IBOutlet var titleLbl: UILabel!
	@IBOutlet var textLbl: UILabel!
	@IBOutlet var actionBtn: UIButton!

	// MARK: - Setup

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func setupView() {
		super.setupView()

		title = previewTitle
		titleLbl.attributedText = titleText.with(style: .regular28, andColor: .black, andLetterSpacing: -0.41)
		textLbl.attributedText = titleText.with(style: .regular20, andColor: .black, andLetterSpacing: -0.41)
		actionBtn.setAttributedTitle(Str.getMoreInformation.with(style: .regular20, andColor: .cursorOrange, andLetterSpacing: -0.41), for: .normal)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func populateData() {
		super.populateData()
	}

	@IBAction func actionBtnTapped(_ sender: Any) {
		// TODO: Action should be implemented.
	}
}
