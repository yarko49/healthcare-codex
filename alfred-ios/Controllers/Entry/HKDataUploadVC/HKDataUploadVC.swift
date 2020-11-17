//
//  HKDataUploadVC.swift
//  alfred-ios
//

import Foundation
import UIKit

class HKDataUploadVC: BaseVC {
	// MARK: - Coordinator Actions

	var queryAction: (() -> Void)?

	// MARK: - Properties

	// MARK: - IBOutlets

	@IBOutlet var titleLbl: UILabel!
	@IBOutlet var waitLbl: UILabel!
	@IBOutlet var progressLbl: UILabel!

	var maxProgress: Int = 0 {
		didSet {
			progressLbl.text = "\(progress)/\(maxProgress)"
		}
	}

	var progress: Int = 0 {
		didSet {
			progressLbl.text = "\(progress)/\(maxProgress)"
		}
	}

	// MARK: - Setup

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func setupView() {
		super.setupView()
	}

	override func localize() {
		super.localize()

		titleLbl.attributedText = Str.importingHealthData.with(style: .regular28, andColor: .black, andLetterSpacing: 0.36)
		waitLbl.attributedText = Str.justASec.with(style: .regular17, andColor: .grey, andLetterSpacing: -0.32)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func populateData() {
		super.populateData()
		queryAction?()
	}
}
