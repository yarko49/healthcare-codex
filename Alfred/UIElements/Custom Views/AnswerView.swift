//
//  QuestionView.swift
//  Alfred
//

import UIKit

protocol AnswerViewViewDelegate: AnyObject {
	func didSelect(selectedAnswerView: AnswerView)
}

class AnswerView: UIView {
	@IBOutlet var contentView: UIView!

	// MARK: - IBOutlets

	@IBOutlet var mainView: UIView!
	@IBOutlet var answerButton: UIButton!
	@IBOutlet var answerLabel: UILabel!
	@IBOutlet var selectionImageView: UIImageView!

	weak var delegate: AnswerViewViewDelegate?
	var buttonViewHeight: CGFloat = 0
	var answer: AnswerOption?
	var isSelected: Bool = false
	var color: UIColor? = .black

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	convenience init(answer: AnswerOption) {
		self.init(frame: CGRect.zero)
		self.answer = answer
		commonInit()
	}

	func commonInit() {
		Bundle.main.loadNibNamed(Self.nibName, owner: self, options: nil)
		contentView.fixInView(self)
		setup()
	}

	func setup() {
		contentView.backgroundColor = .clear
		mainView.backgroundColor = .clear

		setColor()
		if let color = color {
			answerLabel.attributedText = answer?.valueString?.with(style: .regular15, andColor: color)
		}

		buttonViewHeight = answerLabel.heightForView(extraWidth: -56) + 16

		contentView.heightAnchor.constraint(equalToConstant: buttonViewHeight).isActive = true
	}

	func selectAnswer() {
		isSelected.toggle()
		if isSelected {
			selectionImageView.image = UIImage(named: "radioBtnSelected")?.withRenderingMode(.alwaysTemplate)
			selectionImageView.tintColor = color
			return
		}
		selectionImageView.image = UIImage(named: "radioBtnUnselected")?.withRenderingMode(.alwaysTemplate)
		selectionImageView.tintColor = color
	}

	private func setColor() {
		if let answer = answer?.answerOptionExtension, !answer.isEmpty, let colorString = answer[0].valueString?.rawValue {
			color = UIColor(hex: colorString)
		}
		selectionImageView.image = UIImage(named: "radioBtnUnselected")?.withRenderingMode(.alwaysTemplate)
		selectionImageView.tintColor = color
	}

	@IBAction func answerBtnTapped(_ sender: Any) {
		if !isSelected {
			delegate?.didSelect(selectedAnswerView: self)
		}
	}
}
