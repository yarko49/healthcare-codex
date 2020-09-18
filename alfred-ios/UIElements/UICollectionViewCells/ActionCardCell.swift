//
//  MeasurementCardCell.swift
//  alfred-ios
//

import Foundation
import UIKit

class MeasurementCardCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var iconView: CircleProgressBarView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var textLbl: UILabel!
    @IBOutlet weak var statusIV: UIImageView!
    @IBOutlet weak var statusLbl: UILabel!
    
    // MARK: - Vars
    
    var bgColor: UIColor = UIColor.onboardingBackground
    
    // MARK: - Setup
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconView.trackClr = .white
        iconView.progressClr = .orange
        iconView.fillClr = UIColor.lightBackground!
        iconView.setProgressWithAnimation(value: 0.65)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setupView() {
        
        contentView.layer.cornerRadius = 5.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3.0)
        layer.shadowRadius = 8.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        layer.backgroundColor = UIColor.clear.cgColor
        
//        actionIV.image = UIImage(named: "next")?.withRenderingMode(.alwaysTemplate)
//        actionIV.tintColor = UIColor.blue
    }
    
//    func setupCell(with notification: HomeNotification) {
//        setupView()
//
//        homeNotificationDescLbl.text = notification.text
//        dateLbl.text = notification.date
//        actionLbl.text = notification.subtext
//        var image: UIImage?
//
//        switch notification.type {
//        case .behavioralNudge:
//            image = UIImage(named: "yoga")
//        case .questionnaire:
//            image = UIImage(named: "help-circle")
//        case .noType:
//            break
//        }
//        if let image = image {
//            homeNotificationIconIV.image = image
//            homeNotificationIconIV.layer.cornerRadius = 10
//        }
//
//    }
    
    func setupCell(cardTitle: String, cardText: String, time: String, status: String) {
        setupView()
        
        mainView.backgroundColor = bgColor
        
        
        
        titleLbl.attributedText = cardTitle.with(style: .regular13, andColor: .black, andLetterSpacing: -0.408)
        timeLbl.attributedText = time.with(style: .regular13, andColor: .lightGrey, andLetterSpacing: -0.16)
        statusLbl.attributedText = status.with(style: .regular13, andColor: .lightGrey, andLetterSpacing: -0.16)
        
        //TODO: Need to check this again
        let array = cardText.components(separatedBy: " ")
        let attributedString = cardText.with(style: .regular26, andColor: .black, andLetterSpacing: -0.16) as! NSMutableAttributedString
        let range = (cardText as NSString).range(of: array[1])
        attributedString.addAttribute(NSAttributedString.Key.font, value: Font.sfProThin.of(size: 26) , range: range)
        textLbl.attributedText = attributedString
        
    }
    
}
