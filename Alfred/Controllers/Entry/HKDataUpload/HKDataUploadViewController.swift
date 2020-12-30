//
//  HKDataUploadVC.swift
//  Alfred
//

import BonMot
import Foundation
import UIKit

class HKDataUploadViewController: BaseViewController {
	// MARK: - Coordinator Actions

	var queryAction: (() -> Void)?

	// MARK: - Properties

	// MARK: - IBOutlets

	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var waitLabel: UILabel!
	@IBOutlet var progressLabel: UILabel!

	var maxProgress: Int = 0 {
		didSet {
			progressLabel.text = "\(progress)/\(maxProgress)"
		}
	}

	var progress: Int = 0 {
		didSet {
			progressLabel.text = "\(progress)/\(maxProgress)"
		}
	}

	// MARK: - Setup

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.navigationBar.isHidden = true
	}

	override func setupView() {
		super.setupView()
	}

	override func localize() {
		super.localize()

		titleLabel.attributedText = Str.importingHealthData.with(style: .regular28, andColor: .black, andLetterSpacing: 0.36)
		waitLabel.attributedText = Str.justASec.with(style: .regular17, andColor: .grey, andLetterSpacing: -0.32)
	}

	override func populateData() {
		super.populateData()
		queryAction?()
	}
}
