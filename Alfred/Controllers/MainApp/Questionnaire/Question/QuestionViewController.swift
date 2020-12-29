//
//  QuestionVC.swift
//  Alfred
//

import Foundation
import UIKit

class QuestionViewController: BaseViewController {
	// MARK: - Coordinator Actions

	var closeAction: (() -> Void)?
	var getQuestionnaireAction: (() -> Void)?
	var nextQuestionAction: (() -> Void)?
	var onQuestionPartAnsweredAction: ((String, String) -> Void)?

	// MARK: - Properties

	var question: Item?
	var currentQuestionIndex = 0
	var totalQuestions = 0
	var allSubQuestionsAnswered = false
	var multi = false

	// MARK: - IBOutlets

	@IBOutlet var progressBar: UIProgressView!
	@IBOutlet var descriptionLbl: UILabel!
	@IBOutlet var continueView: UIView!
	@IBOutlet var nextQuestionBtn: RoundedButton!
	@IBOutlet var multiPartQuestionsSV: UIStackView!
	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var stackViewCenterXConstraint: NSLayoutConstraint!
	@IBOutlet var questionHeightContraint: NSLayoutConstraint!
	@IBOutlet var continueViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet var scrollViewBottomConstraint: NSLayoutConstraint!

	// MARK: - Setup

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.setNavigationBarHidden(false, animated: false)
	}

	override func setupView() {
		super.setupView()

		stackViewCenterXConstraint.isActive = false
		view.layer.backgroundColor = UIColor.lightBackground?.cgColor
		continueViewBottomConstraint.constant = -continueView.frame.height
		setupProgressBar()
		setupQuestion()
	}

	override func populateData() {
		super.populateData()
	}

	override func viewDidLayoutSubviews() {
		for view in multiPartQuestionsSV.arrangedSubviews where multi {
			view.setShadow()
			view.layer.backgroundColor = UIColor.clear.cgColor
		}

		continueView.setShadow()
		continueView.layer.backgroundColor = UIColor.white.cgColor
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		multiPartQuestionsSV.sizeToFit()
	}

	func setupQuestion() {
		guard let question = question else { return }
		title = Str.question(currentQuestionIndex + 1)
		allSubQuestionsAnswered = false
		changeProgress(step: currentQuestionIndex + 1)

		for view in multiPartQuestionsSV.arrangedSubviews {
			multiPartQuestionsSV.removeArrangedSubview(view)
		}

		scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
		descriptionLbl.attributedText = question.text?.with(style: .regular16, andColor: .black)

		switch question.type {
		case .group:
			if let questionPart = question.item {
				if continueViewBottomConstraint.constant == 0.0, questionPart.contains(where: { $0.selectedAnswerId == nil }) {
					performDisappearAnimation()
				} else if questionPart.contains(where: { $0.selectedAnswerId != nil }) {
					performAppearAnimation()
				}
			}
		case .choice:
			if continueViewBottomConstraint.constant == 0.0, question.selectedAnswerId == nil {
				performDisappearAnimation()
			} else if question.selectedAnswerId != nil {
				performAppearAnimation()
			}
		default:
			break
		}
		multi = question.type == .group
		setupQuestions()
	}

	private func setupProgressBar() {
		progressBar.progressTintColor = .blue
		progressBar.trackTintColor = .gray
		progressBar.layer.cornerRadius = 5
		progressBar.clipsToBounds = true
		progressBar.layer.sublayers?[1].cornerRadius = 4
		progressBar.subviews[1].clipsToBounds = true
	}

	func changeProgress(step: Int) {
		let progress = step != totalQuestions ? Float(Double(step) / Double(totalQuestions)) : 1.0
		progressBar.setProgress(progress, animated: false)
	}

	func setupQuestions() {
		guard let question = question else { return }

		scrollView.isScrollEnabled = multi

		let questionParts = multi ? question.item ?? [] : [question]

		if multi {
			let view0 = UIView()
			multiPartQuestionsSV.addArrangedSubview(view0)
			view0.widthAnchor.constraint(equalToConstant: 0).isActive = true
		}

		var views: [MultiPartAnswerView] = []

		for (index, part) in questionParts.enumerated() {
			let view = MultiPartAnswerView(questionPart: part, currentPart: index + 1, totalParts: questionParts.count)
			view.delegate = self
			multiPartQuestionsSV.addArrangedSubview(view)
			view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 56).isActive = true
			views.append(view)
		}

		if let maxHeight = (views.max { $0.height < $1.height })?.height {
			questionHeightContraint.constant = maxHeight
		}

		if currentQuestionIndex < totalQuestions - 1 {
			nextQuestionBtn.setTitle(Str.next, for: .normal)
		} else {
			nextQuestionBtn.setTitle(Str.submit, for: .normal)
		}
	}

	func allQuestionPartsAnswered() {
		performAppearAnimation()
		allSubQuestionsAnswered = true
	}

	func moveToTheNextQuestionPart(by index: Int) {
		if !allSubQuestionsAnswered {
			scrollView.setContentOffset(CGPoint(x: CGFloat(index) * scrollView.frame.width, y: 0), animated: true)
		}
	}

	fileprivate func performAppearAnimation() {
		UIView.animate(withDuration: 1, delay: 0.5, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.continueViewBottomConstraint.constant = 0
			self.scrollViewBottomConstraint.constant += 40
		}, completion: nil)
	}

	fileprivate func performDisappearAnimation() {
		UIView.animate(withDuration: 1, delay: 0.5, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.continueViewBottomConstraint.constant = -self.continueView.frame.height
			self.scrollViewBottomConstraint.constant -= 40
		}, completion: nil)
	}

	@IBAction func nextQuestionBtnTapped(_ sender: Any) {
		nextQuestionAction?()
	}
}

extension QuestionViewController: MultiPartAnswerViewViewDelegate {
	func didSelect(selectedAnswerId: String, questionPartId: String) {
		onQuestionPartAnsweredAction?(selectedAnswerId, questionPartId)
	}
}
