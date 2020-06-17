//
//  TopLabels.swift
//  alfred-ios

import Foundation
import UIKit



@IBDesignable class TopLabels : UIView {
    
    let kCONTENT_XIB_NAME = "TopLabels"
    
    @IBOutlet weak var contentView : UIView!
    
    @IBOutlet weak var title : UILabel!
    @IBOutlet weak var medianLbl :  UILabel!
    @IBOutlet weak var highgLbl : UILabel!
    @IBOutlet weak var lowLbl : UILabel!
    @IBOutlet weak var medianVal : UILabel!
    @IBOutlet weak var highVal : UILabel!
    @IBOutlet weak var lowVal : UILabel!
    
    @IBOutlet weak var lblSV : UIStackView!
    @IBOutlet weak var valSV : UIStackView!
    @IBOutlet weak var verticalSV : UIStackView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
  
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "TopLabels", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
    }
}

