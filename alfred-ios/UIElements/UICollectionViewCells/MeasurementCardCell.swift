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
    
    var backgroundClr = UIColor.white {
        didSet {
            mainView.backgroundColor = backgroundClr
        }
    }
    
    var statusClr = UIColor.white {
        didSet {
            statusIV.tintColor = statusClr
        }
    }
    
    // MARK: - Setup
    
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
    }
    
    func setupCell(with card: NotificationCardData) {
        setupView()
        
        switch card.backgroundColor {
        case .blue:
            backgroundClr = .weightDataBG
        case .orange:
            backgroundClr = .activityDataBG
        case .red:
            backgroundClr = .bloodPressureDataBG
        case .green:
            backgroundClr = .surveyDataBG
        }
        
        statusIV.image = statusIV.image?.withRenderingMode(.alwaysTemplate)
        
        switch card.statusColor {
        case .brown:
            statusClr = .statusLow
        case .green:
            statusClr = .statusGreen
        case .red:
            statusClr = .statusRed
        case .yellow:
            statusClr = .statusYellow
        case .none:
            break
        }
        
        iconView.setup(color: card.backgroundColor)
        iconView.setProgressWithAnimation(value: 0.65)
        
        titleLbl.attributedText = card.title.with(style: .regular13, andColor: .black, andLetterSpacing: -0.408)
        timeLbl.attributedText = card.sampledTime?.with(style: .regular13, andColor: .lightGrey, andLetterSpacing: -0.16)
        statusLbl.attributedText = card.status?.with(style: .regular13, andColor: .lightGrey, andLetterSpacing: -0.16)
        
        let array = card.text.components(separatedBy: " ")
        let attributedString = card.text.with(style: .regular26, andColor: .black, andLetterSpacing: -0.16) as! NSMutableAttributedString
        if array.count > 1 {
            let range = (card.text as NSString).range(of: array[1])
            attributedString.addAttribute(NSAttributedString.Key.font, value: Font.sfProThin.of(size: 26) , range: range)
        }
        textLbl.attributedText = attributedString
        
    }
    
}
