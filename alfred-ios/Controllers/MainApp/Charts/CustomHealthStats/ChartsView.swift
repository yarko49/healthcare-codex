//
//  ChartsView.swift
//  alfred-ios


import Foundation
import UIKit
import Charts

class ChartsView : UIView {
    
    @IBOutlet weak var contentView : UIView!
    
    @IBOutlet weak var chartView: UIView!
    let kCONTENT_XIB_NAME = "ChartsView"
    
    //var chart : ChartsView?

//    override func resizableSnapshotView(from rect: CGRect, afterScreenUpdates afterUpdates: Bool, withCapInsets capInsets: UIEdgeInsets) -> UIView? {
//
//
//
//        return chart
//    }


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
    }
    
    
    class func instanceFromNib() -> UIView {
           return UINib(nibName: "ChartsView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
       }
       
}

