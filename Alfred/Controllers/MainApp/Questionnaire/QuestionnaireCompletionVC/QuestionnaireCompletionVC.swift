//
//  QuestionnaireCompletionVC.swift
//  alfred-ios
//

import Foundation
import UIKit

class QuestionnaireCompletionVC: BaseVC {
	// MARK: - Coordinator Actions

	var closeAction: (() -> Void)?

	// MARK: - Properties

	// MARK: - IBOutlets

	@IBOutlet var completionIV: UIImageView!
	@IBOutlet var thankYouLbl: UILabel!
	@IBOutlet var descriptionLbl: UILabel!
	@IBOutlet var doneBtn: RoundedButton!

	// MARK: - Setup

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.setNavigationBarHidden(true, animated: false)
	}

	override func setupView() {
		super.setupView()
	}

	override func localize() {
		super.localize()

		thankYouLbl.attributedText = Str.thankYou.with(style: .bold24, andColor: .black)
		descriptionLbl.attributedText = Str.surveySubmit.with(style: .regular16, andColor: .black)
		doneBtn.setTitle(Str.done, for: .normal)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func populateData() {
		super.populateData()
	}

	@IBAction func dobeBtnTapped(_ sender: Any) {
		closeAction?()
	}
}
