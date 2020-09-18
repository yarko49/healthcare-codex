//
//  PatientTrendCell.swift
//  alfred-ios
//

import UIKit

struct PatientTrendCellData {
    var averageValue: Double?
    var highValue: Double?
    var lowValue: Double?
    
}

protocol PatientTrendCellDelegate: NSObject {
    func didTapDetailsView(cell: PatientTrendCell)
}

class PatientTrendCell: UITableViewCell {
    
    @IBOutlet weak var detailsChartStackView: UIStackView!
    @IBOutlet weak var detailsView: UIView!
   
    @IBOutlet weak var chartView: ChartView!
    @IBOutlet weak var trendCategoryImgView: UIImageView!
    @IBOutlet weak var trendTitleLbl: UILabel!
    @IBOutlet weak var averageValueLbl: UILabel!
    @IBOutlet weak var averageTitleLbl: UILabel!
    @IBOutlet weak var highValueLbl: UILabel!
    @IBOutlet weak var highValueTitle: UILabel!
    @IBOutlet weak var lowValueLbl: UILabel!
    @IBOutlet weak var lowValueTitle: UILabel!
    @IBOutlet weak var expandCellImgView: UIImageView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var rightSV: UIStackView!
    @IBOutlet weak var highView: UIView!
    @IBOutlet weak var lowView: UIView!
    
    weak var delegate: PatientTrendCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        expandCellImgView.transform = CGAffineTransform(rotationAngle: 0)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

    
    var highVal: String? {
        didSet {
            highValueLbl.attributedText = highVal?.with(style: .regular16, andColor: .black, andLetterSpacing: -0.32)
        }
    }
    
    var lowVal: String? {
        didSet {
            lowValueLbl.attributedText = lowVal?.with(style: .regular16, andColor: .black, andLetterSpacing: -0.32)
        }
    }
    
    func setupCell(data: PatientTrendCellData,
                   type: HealthKitQuantityType,
                   healthStatsDateIntervalType: HealthStatsDateIntervalType,
                   shouldShowChart: Bool) {
        
        var text = ""
        
        switch healthStatsDateIntervalType {
            
            // Mock data , hardcoded strings will be removed after the release
            
        case .daily :
            switch type {
            case .weight:
                text = "Now"
            case .activity:
                text = "Yesterday"
            case .bloodPressure:
                text = "11:32 AM"
            case .restingHR:
                text = "6:32 PM"
            case .heartRate:
                text = "7:00 PM"
            }
            
            
            dateLbl.attributedText = text.with(style: .regular16, andColor: .lightGray, andLetterSpacing: -0.408)
            dateLbl.textAlignment = NSTextAlignment.right
            dateLbl.numberOfLines = 1
            dateLbl.isHidden = false
            expandCellImgView.isHidden = true
            chartView.isHidden = true
            setupCollapsedCellValues(type: type, data: data, healthStatsDateIntervalType: healthStatsDateIntervalType)
            
        case .monthly, .weekly , .yearly :
            dateLbl.isHidden = true
            expandCellImgView.isHidden = false
            expandCellImgView.image = UIImage(named:"expandBtn")
            addTapGestureForExpanding()
            setupChart(shouldShowChart: shouldShowChart, type : healthStatsDateIntervalType)
            setupCollapsedCellValues(type: type, data: data, healthStatsDateIntervalType: healthStatsDateIntervalType)
        }
        
    }
    
    private func addTapGestureForExpanding() {
        let tapDetailesViewGesture = UITapGestureRecognizer(target: self, action: #selector(didTapDetailsView))
        detailsView.isUserInteractionEnabled = true
        detailsView.addGestureRecognizer(tapDetailesViewGesture)
    }
    
    
    private func setupCollapsedCellValues(type: HealthKitQuantityType,
                                          data: PatientTrendCellData,
                                          healthStatsDateIntervalType: HealthStatsDateIntervalType){
        
        trendTitleLbl.attributedText = type.rawValue.with(style: .semibold20, andColor: type.getColor())
        trendCategoryImgView.image = type.getImage()
        
        //Mock Data
        switch healthStatsDateIntervalType {
            
        case .daily:
            let string = setupWeightMessage(type : type)
            averageTitleLbl.attributedText = string.with(style: .regular13, andColor: .lightGrey)
            averageValueLbl.attributedText = getAvg(type: type, int : healthStatsDateIntervalType)
        case .weekly:
            averageTitleLbl.attributedText = Str.weeklyAverage.with(style: .regular15, andColor: .lightGray)
            averageValueLbl.attributedText = getAvg(type: type, int : healthStatsDateIntervalType)
        case .monthly:
            averageTitleLbl.attributedText = Str.monthlyAverage.with(style: .regular15, andColor: .lightGray)
            averageValueLbl.attributedText = getAvg(type: type, int : healthStatsDateIntervalType)
        case .yearly:
            averageTitleLbl.attributedText = Str.yearlyAverage.with(style: .regular15, andColor: .lightGray)
            averageValueLbl.attributedText = getAvg(type: type, int : healthStatsDateIntervalType)
        }
    }
    
    //Provides Mock data to cards
    
    func getAvg(type : HealthKitQuantityType, int : HealthStatsDateIntervalType) -> NSMutableAttributedString {
        
        var title = NSMutableAttributedString(string: "")
        var val = "0"
        highValueTitle.attributedText = Str.high.with(style: .regular15, andColor: .lightGray, andLetterSpacing: -0.408)
        lowValueTitle.attributedText = Str.low.with(style: .regular15, andColor: .lightGray, andLetterSpacing: -0.408)
        switch type {
        case .weight:
            val = "184"
            switch int {
            case .daily:
                
                changeVisibilityViews(show: false)
                
            default:
                changeVisibilityViews(show: true)
                highVal = "250 lbs"
                lowVal = "165 lbs"
            }
        case .activity:
            switch int {
            case .daily:
                val = "9,000"
                changeVisibilityViews(show: false)
                
            case .weekly, .monthly, .yearly:
                val = "11,564"
                changeVisibilityViews(show: true)
                highVal = "13,000"
                lowVal = "9,000"
            }
        case .bloodPressure:
            val = "120/79"
            switch int{
            case .daily:
                changeVisibilityViews(show: false)
            default:
                changeVisibilityViews(show: true)
                highVal = "130/90"
                lowVal = "98/66"
            }
        case .restingHR:
            switch int {
            case .daily:
                val = "73"
                changeVisibilityViews(show: false)
            case .weekly, .monthly, .yearly:
                val = "62"
                changeVisibilityViews(show: true)
                highVal = "99 bpm"
                lowVal = "30 bpm"
            }
        case .heartRate:
            switch int{
                
            case .daily:
                val = "56"
                changeVisibilityViews(show: false)
            default:
                val = "56"
                changeVisibilityViews(show: true)
                highVal = "76 bpm"
                lowVal = "45 bpm"
            }
        }
        
        let units = type.getUnit().with(style: .regular17, andColor: .black, andLetterSpacing: -0.00001)
        title = val.with(style: .regular26 , andColor: .black) as! NSMutableAttributedString
        title.append(NSAttributedString(string: " "))
        title.append((units))
        return title
    }
    
    
    func changeVisibilityViews(show: Bool){
        highValueLbl.isHidden = !show
        highValueTitle.isHidden = !show
        lowValueLbl.isHidden = !show
        lowValueTitle.isHidden = !show
    }
    
    
    //Provides Mock data to cards
    
    func setupWeightMessage(type : HealthKitQuantityType) -> NSMutableAttributedString {
        switch type {
        case .weight:
            return getWeightMessage(message: Str.healthy, image: UIImage(named: "healthy"))
        case .activity:
            return getWeightMessage(message: "On Track", image: UIImage(named: "healthy"))
        case .bloodPressure:
            return getWeightMessage(message: Str.elevated, image: UIImage(named: "heavy"))
        case .restingHR:
            return getWeightMessage(message: Str.healthy, image: UIImage(named: "healthy"))
        case .heartRate:
            return getWeightMessage(message: Str.healthy, image: UIImage(named: "healthy"))
        }
    }
    
    private func getWeightMessage(message: String, image: UIImage?) -> NSMutableAttributedString {
        let dailyString = NSMutableAttributedString(string:"")
        let dailyAttachment = NSTextAttachment()
        dailyAttachment.image = image
        let imageString = NSAttributedString(attachment: dailyAttachment)
        dailyString.append(imageString)
        dailyString.append(NSAttributedString(string:" "))
        dailyString.append(NSAttributedString(string: message))
        return dailyString
    }
    
    private func setupChart(shouldShowChart: Bool, type: HealthStatsDateIntervalType) {
        chartView.isHidden = !shouldShowChart
        expandCellImgView.transform = CGAffineTransform(rotationAngle: shouldShowChart ? CGFloat.pi : 0)
        chartView.refreshChart(type : type)
        detailsChartStackView.addArrangedSubview(chartView)
        
    }
    
    @objc func didTapDetailsView() {
        delegate?.didTapDetailsView(cell: self)
    }
    
}
