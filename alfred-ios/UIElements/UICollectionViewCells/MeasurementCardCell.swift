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
    @IBOutlet weak var addIV: UIImageView!
    @IBOutlet weak var surveyLbl: UILabel!
    @IBOutlet weak var surveyIV: UIImageView!
    
    // MARK: - Vars
    var card: NotificationCardData?
    
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
    
    var title: String? {
        didSet {
            if let title = title {
                titleLbl.attributedText = title.with(style: .regular13, andColor: .black, andLetterSpacing: -0.408)
            }
        }
    }
    
    var timestamp: String? {
        didSet {
            if let timestamp = timestamp, let date = DateFormatter.wholeDate.date(from: timestamp) {
                var dateString = ""
                
                if Calendar.current.isDateInToday(date) {
                    let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: date, to: Date())
                    let hours = diffComponents.hour
                    dateString = hours == 0 ? Str.now : DateFormatter.HHmm.string(from: date)
                } else if Calendar.current.isDateInYesterday(date) {
                    dateString = Str.yesterday
                } else {
                    dateString = DateFormatter.MMMdd.string(from: date)
                }
                
                timeLbl.attributedText = dateString.with(style: .regular13, andColor: .lightGrey, andLetterSpacing: -0.16)
            }
        }
    }
    
    var status: String? {
        didSet {
            if let status = status {
               statusLbl.attributedText = status.with(style: .regular13, andColor: .lightGrey, andLetterSpacing: -0.16)
            }
        }
    }
    
    var text: String? {
        didSet {
            if let text = text {
                textLbl.attributedText = setAttributedString(for: text)
                setAppearanceForDataInput(flag: false)
            } else {
                setCellForDataInput()
                setAppearanceForDataInput(flag: true)
            }
            
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
        
        self.card = card
        
        if let color = UIColor(hex: card.backgroundColor) {
            backgroundClr = color
        }
        
        statusIV.image = statusIV.image?.withRenderingMode(.alwaysTemplate)
        
        if let statusColorHex = card.statusColor, let color = UIColor(hex: statusColorHex) {
            statusClr = color
        }
        
        if let color = card.progressColor, let opacity = card.progressOpacity, let progress = card.progressPercent, let icon = card.icon {
            iconView.setup(color: color, opacity: opacity, icon: icon)
            iconView.setProgressWithAnimation(value: progress)
        }
        
        surveyLbl.attributedText = Str.completeSurvey.with(style: .regular13, andColor: .lightGrey, andLetterSpacing: -0.16)
        let surveyImage = surveyIV.image?.withRenderingMode(.alwaysTemplate)
        surveyIV.image = surveyImage
        surveyIV.tintColor = .lightGrey
        
        self.title = card.title
        self.timestamp = card.sampledTime
        self.status = card.status
        self.text = card.text
        setAppeareanceOnAction(action: card.action)
    }
    
    private func setAttributedString(for text: String) -> NSMutableAttributedString {
        let array = text.components(separatedBy: " ")
        let attributedString = text.with(style: .regular26, andColor: .black, andLetterSpacing: -0.16) as! NSMutableAttributedString
        if array.count > 1 {
            let range = (text as NSString).range(of: array[1])
            attributedString.addAttribute(NSAttributedString.Key.font, value: Font.sfProThin.of(size: 26) , range: range)
        }
        return attributedString
    }
    
    private func setCellForDataInput() {
        switch card?.action {
        case .bloodPressure:
            textLbl.attributedText = Str.enterBP.with(style: .regular24, andColor: .enterGrey, andLetterSpacing: -0.16)
        case .weight:
            textLbl.attributedText = Str.enterWeight.with(style: .regular24, andColor: .enterGrey, andLetterSpacing: -0.16)
        default:
            break
        }
    }
    
    private func setAppeareanceOnAction(action: CardAction?) {
        let questionnaireFlag = action == .questionnaire
        if questionnaireFlag {
            statusLbl.isHidden = questionnaireFlag
            statusIV.isHidden = questionnaireFlag
            timeLbl.isHidden = questionnaireFlag
            addIV.isHidden = questionnaireFlag
        }
        surveyIV.isHidden = !questionnaireFlag
        surveyLbl.isHidden = !questionnaireFlag
    }
    
    private func setAppearanceForDataInput(flag: Bool) {
        addIV.isHidden = !flag
        statusIV.isHidden = flag
        statusLbl.isHidden = flag
        timeLbl.isHidden = flag
    }
    
}
