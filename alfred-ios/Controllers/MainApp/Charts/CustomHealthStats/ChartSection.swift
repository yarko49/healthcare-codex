//
//  ChartSection.swift
//  alfred-ios



import Foundation
import UIKit
import Charts

class ChartSection : UIView {
    let kCONTENT_XIB_NAME = "ChartSection"
    let kCONTENT_XIB_NAME_TOP = "TopLabels"
    let kCONTENT_XIB_NAME_BOTTOM = "BottomLabels"
    let kCONTENT_XIB_NAME_CHART = "ChartsView"
    @IBOutlet weak var stackView : UIStackView!
    @IBOutlet weak var contentView : UIView!
    
    
    
    enum view{
        case ChartsView
        case Bottom
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "ChartSection", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
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
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        
        let sectionOne = TopLabels.instanceFromNib()
        let sectionTwo = ChartsView.instanceFromNib()
        let sectionThree = BottomLabels.instanceFromNib()
        stackView.addArrangedSubview(sectionOne)
        stackView.addArrangedSubview(sectionTwo)
        stackView.addArrangedSubview(sectionThree)
        setupLayout()
        
       
    }
    
    
    func setupLayout(){
        //Stack view is 356 x 654
        
        
        
        
        
        
    }
    
    
    
    
}



