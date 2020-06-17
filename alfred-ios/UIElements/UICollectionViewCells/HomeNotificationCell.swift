//
//  HomeNotificationCell.swift
//  alfred-ios
//

import Foundation
import UIKit

class HomeNotificationCell: UICollectionViewCell {
    
    @IBOutlet weak var homeNotificationDescLbl: UILabel!
    @IBOutlet weak var homeNotificationIconIV: UIImageView!
    @IBOutlet weak var actionIconIV: UIImageView!
    @IBOutlet weak var smallIconIV: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setupView() {
        
        contentView.layer.cornerRadius = 15.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowRadius = 6.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        layer.backgroundColor = UIColor.clear.cgColor
        
        actionIconIV.image = UIImage(named: "next")?.withRenderingMode(.alwaysTemplate)
        actionIconIV.tintColor = UIColor.grey
        
    }
    
    func setupCell(text: String, type: HomeNotificationType) {
        setupView()
        
        homeNotificationDescLbl.text = text
        var image: UIImage?
        switch type {
        case .behavioralNudge:
            image = UIImage(named: "heartPlaceholder")
            smallIconIV.isHidden = true
        case .questionaire:
            image = UIImage(named: "heartPlaceholder")?.withRenderingMode(.alwaysTemplate)
            homeNotificationIconIV.tintColor = .purple
            smallIconIV.isHidden = false
            smallIconIV.image = UIImage(named: "tinyIconPlaceholder")
            smallIconIV.layer.cornerRadius = 5
        case .noType:
            break
        }
        if let image = image {
            homeNotificationIconIV.image = image
            homeNotificationIconIV.layer.cornerRadius = 10
        }
        
    }
    
}
