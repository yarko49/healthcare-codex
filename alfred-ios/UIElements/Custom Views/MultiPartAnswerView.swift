//
//  MultiPartAnswerView.swift
//  alfred-ios
//

import UIKit

protocol MultiPartAnswerViewViewDelegate: AnyObject {
	func didSelect(selectedAnswerId: String, questionPartId: String)
}

class MultiPartAnswerView: UIView {
	@IBOutlet var contentView: UIView!

	let kCONTENT_XIB_NAME = "MultiPartAnswerView"

	// MARK: - IBOutlets

	@IBOutlet var mainView: UIView!
	@IBOutlet var partsLbl: UILabel!
	@IBOutlet var titleLbl: UILabel!
	@IBOutlet var sv: UIStackView!
	@IBOutlet var svHeightConstraint: NSLayoutConstraint!

	var height: CGFloat = 0
	var questionPart: Item?
	var currentPart: Int = 0
	var totalParts: Int = 0

	var baseContentHeight: CGFloat = 62

	weak var delegate: MultiPartAnswerViewViewDelegate?
	var selectedAnswerView: AnswerView?

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	convenience init(questionPart: Item, currentPart: Int, totalParts: Int) {
		self.init(frame: CGRect.zero)
		self.questionPart = questionPart
		self.currentPart = currentPart
		self.totalParts = totalParts
		commonInit()
	}

	func commonInit() {
		Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
		contentView.fixInView(self)
		setupPart(with: totalParts > 1)
	}

	func setupPart(with multi: Bool) {
		contentView.layer.cornerRadius = 15.0
		contentView.layer.borderWidth = 1.0
		contentView.layer.borderColor = multi ? UIColor.black.withAlphaComponent(0.2).cgColor : UIColor.clear.cgColor
		contentView.layer.masksToBounds = true
		mainView.backgroundColor = multi ? UIColor.white : UIColor.clear
		contentView.backgroundColor = multi ? UIColor.white : UIColor.clear

		guard let answers = questionPart?.answerOption else { return }

		partsLbl.attributedText = multi ? Str.ofParts(currentPart, totalParts).uppercased().with(style: .regular12, andColor: .lightGrey, andLetterSpacing: 0.16) : "".with(.regular13)
		titleLbl.attributedText = multi ? questionPart?.text?.with(style: .bold16, andColor: .black) : "".with(.regular13)

		baseContentHeight += titleLbl.heightForView() + partsLbl.heightForView()

		for answer in answers {
			let view = AnswerView(answer: answer)

			if let selectedAnswerId = questionPart?.selectedAnswerId, selectedAnswerId == answer.valueString {
				view.selectAnswer()
				selectedAnswerView = view
			}

			view.delegate = self
			height += view.buttonViewHeight
			sv.addArrangedSubview(view)
		}

		height += baseContentHeight

		svHeightConstraint.constant = height - baseContentHeight
	}
}

extension MultiPartAnswerView: AnswerViewViewDelegate {
	func didSelect(selectedAnswerView: AnswerView) {
		if let oldSelectedAnswer = self.selectedAnswerView?.answer, let newSelectedAnswer = selectedAnswerView.answer {
			if oldSelectedAnswer != newSelectedAnswer {
				selectedAnswerView.selectAnswer()
				self.selectedAnswerView?.selectAnswer()
				self.selectedAnswerView = selectedAnswerView
			}

		} else {
			selectedAnswerView.selectAnswer()
			self.selectedAnswerView?.selectAnswer()
			self.selectedAnswerView = selectedAnswerView
		}

		if let answer = selectedAnswerView.answer, let questionPart = questionPart, let id = answer.valueString {
			delegate?.didSelect(selectedAnswerId: id, questionPartId: questionPart.linkID)
		}
	}
}
