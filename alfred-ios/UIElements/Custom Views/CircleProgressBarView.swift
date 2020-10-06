//
//  CardProgressBarView.swift
//  alfred-ios
//

import Foundation
import UIKit


class CircleProgressBarView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var iconIV: UIImageView!
    
    let kCONTENT_XIB_NAME = "CircleProgressBarView"
    
    // MARK: - IBOutlets
    
    private var progressLyr = CAShapeLayer()
    private var trackLyr = CAShapeLayer()
    
    var progressClr = UIColor.white {
        didSet {
            progressLyr.strokeColor = progressClr.cgColor
        }
    }
    var trackClr = UIColor.white {
        didSet {
            trackLyr.strokeColor = trackClr.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
    }
    
    func setup(color: String, opacity: Float, icon: IconType) {
        
        switch icon {
        case .scale:
            iconIV.image = UIImage(named: "weightCardIcon")
        case .activity:
            iconIV.image = UIImage(named: "activityCardIcon")
        case .heart:
            iconIV.image = UIImage(named: "bloodPressureCardIcon")
        case .questionnaire:
            iconIV.image = UIImage(named: "surveyCardIcon")
        }
        
        if let color = UIColor(hex: color) {
          progressClr = color
        }
        
        trackClr = progressClr.withAlphaComponent(CGFloat(opacity)/4.0)
        makeCircularPath()
        
        self.backgroundColor = UIColor.white.withAlphaComponent(CGFloat(opacity)/2.0)
    }
    
    private func makeCircularPath() {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.frame.size.width/2
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2), radius: (frame.size.width - 1.5)/2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        trackLyr.path = circlePath.cgPath
        trackLyr.fillColor = UIColor.clear.cgColor
        trackLyr.strokeColor = trackClr.cgColor
        trackLyr.lineWidth = 3.0
        trackLyr.strokeEnd = 1.0
        layer.addSublayer(trackLyr)
        progressLyr.path = circlePath.cgPath
        progressLyr.fillColor = UIColor.clear.cgColor
        progressLyr.strokeColor = progressClr.cgColor
        progressLyr.lineWidth = 3.0
        progressLyr.strokeEnd = 0.0
        layer.addSublayer(progressLyr)
    }
    
    func setProgressWithAnimation(value: Float) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1.0
        animation.fromValue = 0
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLyr.strokeEnd = CGFloat(value)
        progressLyr.add(animation, forKey: "animateprogress")
    }
}
