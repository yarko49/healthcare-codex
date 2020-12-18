//
//  QuestionnaireVC.swift
//  alfred-ios
//

import Foundation
import UIKit

class QuestionnaireVC: BaseViewController {
	// MARK: - Coordinator Actions

	var closeAction: (() -> Void)?
	var showQuestionnaireAction: (() -> Void)?

	// MARK: - Properties

	// MARK: - IBOutlets

	@IBOutlet var closeBtn: UIButton!
	@IBOutlet var iconIV: UIImageView!
	@IBOutlet var titleLbl: UILabel!
	@IBOutlet var descriptionLbl: UILabel!
	@IBOutlet var startQuestionnaireBtn: RoundedButton!

	// MARK: - Setup

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.setNavigationBarHidden(true, animated: false)
	}

	override func setupView() {
		super.setupView()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// self.addBottomSheetView()
	}

	override func populateData() {
		super.populateData()
	}

	@IBAction func close(_ sender: Any) {
		closeAction?()
	}

	@IBAction func showQuestionnaire(_ sender: Any) {
		showQuestionnaireAction?()
	}
}
