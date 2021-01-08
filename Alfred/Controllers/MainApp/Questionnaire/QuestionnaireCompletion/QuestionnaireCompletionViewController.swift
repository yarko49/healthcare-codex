//
//  QuestionnaireCompletionViewController.swift
//  Alfred
//

import Foundation
import UIKit

class QuestionnaireCompletionViewController: BaseViewController {
	// MARK: - Coordinator Actions

	var closeAction: (() -> Void)?

	// MARK: - Properties

	// MARK: - IBOutlets

	@IBOutlet var completionImageView: UIImageView!
	@IBOutlet var thankYouLabel: UILabel!
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var doneButton: RoundedButton!

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

		thankYouLabel.attributedText = Str.thankYou.with(style: .bold24, andColor: .black)
		descriptionLabel.attributedText = Str.surveySubmit.with(style: .regular16, andColor: .black)
		doneButton.setTitle(Str.done, for: .normal)
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
