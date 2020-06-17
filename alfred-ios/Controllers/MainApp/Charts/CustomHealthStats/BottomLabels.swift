//
//  BottomLabels.swift
//  alfred-ios


import UIKit
import Foundation

class BottomLabels: UIView {
    
   let kCONTENT_XIB_NAME = "BottomLabels"
    
//-MARK: IBOutlets
    
    @IBOutlet weak var contentView : UIView!
    
    @IBOutlet weak var targetLbl : UILabel!
    @IBOutlet weak var targetVal : UILabel!
    @IBOutlet weak var highLbl : UILabel!
    @IBOutlet weak var medianLbl : UILabel!
    @IBOutlet weak var lowLbl : UILabel!
    @IBOutlet weak var highValLbl : UILabel!
    @IBOutlet weak var medianValLbl : UILabel!
    @IBOutlet weak var lowValLbl : UILabel!
    
    @IBOutlet weak var valSV: UIStackView!
    @IBOutlet weak var lblSV: UIStackView!
    @IBOutlet weak var verticalSV: UIStackView!
    @IBOutlet weak var targetSV : UIStackView!
    @IBOutlet weak var totalBottomSV : UIStackView!
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        populateData()
        setUpNib()
    }
    
    class func instanceFromNib() -> UIView {
           return UINib(nibName: "BottomLabels", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
       }
    
    func populateData(){
       
        
        
        
    }
    
    func setUpNib(){
        
        
    }
       
}





