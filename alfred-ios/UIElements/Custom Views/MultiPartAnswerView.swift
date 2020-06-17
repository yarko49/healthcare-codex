//
//  MultiPartAnswerView.swift
//  alfred-ios
//

import UIKit

class MultiPartAnswerView: UIView {
    @IBOutlet weak var contentView: UIView!
    
    let kCONTENT_XIB_NAME = "MultiPartAnswerView"
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var answerBtn: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        setup()
    }
    
    func setup() {
        
    }
}
