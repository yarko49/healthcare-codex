//
//  QuestionView.swift
//  alfred-ios
//

import UIKit

protocol AnswerViewViewDelegate: AnyObject {
    func didSelect(selectedAnswerView: AnswerView)
}

class AnswerView: UIView {
    @IBOutlet weak var contentView: UIView!
    
    let kCONTENT_XIB_NAME = "AnswerView"
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var answerBtn: UIButton!
    @IBOutlet weak var answerLbl: UILabel!
    @IBOutlet weak var selectionIV: UIImageView!
    
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
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        setup()
    }
    
    func setup() {
        contentView.backgroundColor = .clear
        mainView.backgroundColor = .clear
        
        self.setColor()
        if let color = color {
            answerLbl.attributedText = answer?.valueString?.with(style: .regular15, andColor: color)
        }
        
        buttonViewHeight = answerLbl.heightForView(extraWidth: -56) + 16
        
        contentView.heightAnchor.constraint(equalToConstant: buttonViewHeight).isActive = true
    }
    
    func selectAnswer() {
        isSelected.toggle()
        if isSelected {
            selectionIV.image = UIImage(named: "radioBtnSelected")?.withRenderingMode(.alwaysTemplate)
            selectionIV.tintColor = color
            return
        }
        selectionIV.image = UIImage(named: "radioBtnUnselected")?.withRenderingMode(.alwaysTemplate)
        selectionIV.tintColor = color
    }
    
    private func setColor() {
        if let answer = answer?.answerOptionExtension, answer.count > 0, let colorString = answer[0].valueString?.rawValue {
            color = UIColor(hex: colorString)
        }
        selectionIV.image = UIImage(named: "radioBtnUnselected")?.withRenderingMode(.alwaysTemplate)
        selectionIV.tintColor = color
    }
    
    @IBAction func answerBtnTapped(_ sender: Any) {
        if !isSelected {
            delegate?.didSelect(selectedAnswerView: self)
        }
    }

}
