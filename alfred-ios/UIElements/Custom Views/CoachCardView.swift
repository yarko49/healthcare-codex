//
//  CoachCardView.swift
//  alfred-ios
//

import Foundation
import UIKit

protocol CoachCardViewDelegate: AnyObject {
    func actionBtnTapped()
    func closeBtnTapped(uuid: String)
}

class CoachCardView: UIView {
    @IBOutlet weak var contentView: UIView!
    
    let kCONTENT_XIB_NAME = "CoachCardView"
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var actionBtn: UIButton!
    
    weak var delegate: CoachCardViewDelegate?
    var card: NotificationCardData?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(card: NotificationCardData) {
        self.init(frame: CGRect.zero)
        self.card = card
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        setup()
    }
    
    func setup() {

        guard let card = card else {return}
        
        titleLbl.attributedText = card.previewTitle?.with(style: .bold17, andColor: .white, andLetterSpacing: -0.32)
        descLbl.attributedText = card.previewText?.with(style: .regular17, andColor: .white, andLetterSpacing: -0.32)
        actionBtn.setAttributedTitle("Troubleshooting Guide".uppercased().with(style: .bold17, andColor: .white, andLetterSpacing: -0.32), for: .normal)
        
        switch card.backgroundColor {
        case .blue:
            view.backgroundColor = .weightBG
        case .orange:
            view.backgroundColor = .activityBG
        case .red:
            view.backgroundColor = .bloodPressureBG
        case .green:
            view.backgroundColor = .surveyBG
        }
    }
    
    @IBAction func actionBtnTapped(_ sender: Any) {
        delegate?.actionBtnTapped()
    }
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        guard let id = card?.uuid else {return}
        delegate?.closeBtnTapped(uuid: id)
    }
    
}
