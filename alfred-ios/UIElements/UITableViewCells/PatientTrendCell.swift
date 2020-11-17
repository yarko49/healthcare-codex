//
//  PatientTrendCell.swift
//  alfred-ios
//

import HealthKit
import UIKit
struct TodaySampleModel {
	let samples: [HKQuantitySample]
	let description: String
	let date: Date
}

struct PatientTrendCellData {
	var averageValue: Int?
	var highValue: Int?
	var lowValue: Int?
}

struct ChartData {
	var xValues: [String]?
	var yValues: [Int]?
}

protocol PatientTrendCellDelegate: NSObject {
	func didTapDetailsView(cell: PatientTrendCell)
}

class PatientTrendCell: UITableViewCell {
	@IBOutlet var detailsChartStackView: UIStackView!
	@IBOutlet var detailsView: UIView!
	@IBOutlet var chartView: ChartView!
	@IBOutlet var trendCategoryImgView: UIImageView!
	@IBOutlet var trendTitleLbl: UILabel!
	@IBOutlet var averageValueLbl: UILabel!
	@IBOutlet var averageTitleLbl: UILabel!
	@IBOutlet var highValueLbl: UILabel!
	@IBOutlet var highValueTitle: UILabel!
	@IBOutlet var lowValueLbl: UILabel!
	@IBOutlet var lowValueTitle: UILabel!
	@IBOutlet var expandCellImgView: UIImageView!
	@IBOutlet var dateLbl: UILabel!
	@IBOutlet var rightSV: UIStackView!
	@IBOutlet var highView: UIView!
	@IBOutlet var lowView: UIView!

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
	               healthStatsDateIntervalType: HealthStatsDateIntervalType, chartData: ChartData,
	               shouldShowChart: Bool)
	{
		var text = ""

		switch healthStatsDateIntervalType {
            // Mock data , hardcoded strings will be removed after the release

		case .daily:
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

		case .monthly, .weekly, .yearly:
			dateLbl.isHidden = true
			expandCellImgView.isHidden = false
			expandCellImgView.image = UIImage(named: "expandBtn")
			addTapGestureForExpanding()
			setupChart(shouldShowChart: shouldShowChart, type: healthStatsDateIntervalType, data: chartData)
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
	                                      healthStatsDateIntervalType: HealthStatsDateIntervalType)
	{
		trendTitleLbl.attributedText = type.rawValue.with(style: .semibold20, andColor: type.getColor())
		trendCategoryImgView.image = type.getImage()

		// Mock Data
		switch healthStatsDateIntervalType {
		case .daily:
			let string = setupWeightMessage(type: type)
			averageTitleLbl.attributedText = string.with(style: .regular13, andColor: .lightGrey)
			averageValueLbl.attributedText = getAvg(type: type, int: healthStatsDateIntervalType)
		case .weekly:
			averageTitleLbl.attributedText = Str.weeklyAverage.with(style: .regular15, andColor: .lightGray)
			averageValueLbl.attributedText = getAvg(type: type, int: healthStatsDateIntervalType)
		case .monthly:
			averageTitleLbl.attributedText = Str.monthlyAverage.with(style: .regular15, andColor: .lightGray)
			averageValueLbl.attributedText = getAvg(type: type, int: healthStatsDateIntervalType)
		case .yearly:
			averageTitleLbl.attributedText = Str.yearlyAverage.with(style: .regular15, andColor: .lightGray)
			averageValueLbl.attributedText = getAvg(type: type, int: healthStatsDateIntervalType)
		}
	}

	// Provides Mock data to cards

	func getAvg(type: HealthKitQuantityType, int: HealthStatsDateIntervalType) -> NSMutableAttributedString {
		var title = NSMutableAttributedString(string: "")
		var val = ""
		highValueTitle.attributedText = Str.high.with(style: .regular15, andColor: .lightGray, andLetterSpacing: -0.408)
		lowValueTitle.attributedText = Str.low.with(style: .regular15, andColor: .lightGray, andLetterSpacing: -0.408)
		switch type {
		case .weight:
			val = ""
			switch int {
			case .daily:

				changeVisibilityViews(show: false)

			default:
				changeVisibilityViews(show: true)
				//                highVal = ""
				//                lowVal = ""
			}
		case .activity:
			switch int {
			case .daily:
				val = ""
				changeVisibilityViews(show: false)

			case .weekly, .monthly, .yearly:
				val = ""
				changeVisibilityViews(show: true)
				//                highVal = ""
				//                lowVal = ""
			}
		case .bloodPressure:
			val = ""
			switch int {
			case .daily:
				changeVisibilityViews(show: false)
			default:
				changeVisibilityViews(show: true)
				//                highVal = ""
				//                lowVal = ""
			}
		case .restingHR:
			switch int {
			case .daily:
				val = ""
				changeVisibilityViews(show: false)
			case .weekly, .monthly, .yearly:
				// val = ""
				changeVisibilityViews(show: true)
				highVal = ""
				lowVal = ""
			}
		case .heartRate:
			switch int {
			case .daily:
				// val = "56"
				changeVisibilityViews(show: false)
			default:
				val = "56"
				changeVisibilityViews(show: true)
				//                highVal = "76 bpm"
				//                lowVal = "45 bpm"
			}
		}

		let units = type.getUnit().with(style: .regular17, andColor: .black, andLetterSpacing: -0.00001)
		title = val.with(style: .regular26, andColor: .black) as! NSMutableAttributedString
		title.append(NSAttributedString(string: " "))
		title.append(units)
		return title
	}

	func changeVisibilityViews(show: Bool) {
		highValueLbl.isHidden = !show
		highValueTitle.isHidden = !show
		lowValueLbl.isHidden = !show
		lowValueTitle.isHidden = !show
	}

	// Provides Mock data to cards

	func setupWeightMessage(type: HealthKitQuantityType) -> NSMutableAttributedString {
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
		let dailyString = NSMutableAttributedString(string: "")
		let dailyAttachment = NSTextAttachment()
		dailyAttachment.image = image
		let imageString = NSAttributedString(attachment: dailyAttachment)
		dailyString.append(imageString)
		dailyString.append(NSAttributedString(string: " "))
		dailyString.append(NSAttributedString(string: message))
		return dailyString
	}

	private func setupChart(shouldShowChart: Bool, type: HealthStatsDateIntervalType, data: ChartData) {
		chartView.isHidden = !shouldShowChart
		expandCellImgView.transform = CGAffineTransform(rotationAngle: shouldShowChart ? CGFloat.pi : 0)
		chartView.refreshChart(type: type)
		detailsChartStackView.addArrangedSubview(chartView)
	}

	@objc func didTapDetailsView() {
		delegate?.didTapDetailsView(cell: self)
	}

	func setup(for quantityType: HealthKitQuantityType, with data: [HKQuantitySample]) {
		highView.isHidden = true
		lowView.isHidden = true
		chartView.isHidden = true
		trendTitleLbl.attributedText = quantityType.rawValue.with(style: .semibold20, andColor: quantityType.getColor())
		trendCategoryImgView.image = quantityType.getImage()
		switch quantityType {
		case .weight, .heartRate, .restingHR:
			averageValueLbl.attributedText = data.first?.description.with(style: .regular26, andColor: .black)
		case .bloodPressure where data.count == 2:
			let pressureData = data.sorted { (sample1, sample2) -> Bool in
				let sample1Double = sample1.quantity.doubleValue(for: .millimeterOfMercury())
				let sample2Double = sample2.quantity.doubleValue(for: .millimeterOfMercury())
				return sample1Double > sample2Double
			}.map { Int($0.quantity.doubleValue(for: .millimeterOfMercury())) }
			guard let systolic = pressureData.first, let diastolic = pressureData.last else { return }
			averageValueLbl.attributedText = "\(systolic)/\(diastolic)\(quantityType.hkUnit.description)".with(style: .regular26, andColor: .black)
		default:
			break
		}
		averageValueLbl.attributedText = data.description.with(style: .regular26, andColor: .black)
	}

	func setupStatusMessage(type: HealthKitQuantityType, value1: Double, value2: Double) -> NSMutableAttributedString {
		switch type {
		case .weight:
			if value1 < 110.0 {
				return getStatusMessage(message: "Below normal", image: UIImage(named: "obese"))
			} else if value1 < 180, value1 > 110 {
				return getStatusMessage(message: Str.healthy, image: UIImage(named: "healthy"))
			}
			else if value1 < 220 {
				return getStatusMessage(message: Str.heavy, image: UIImage(named: "heavy"))
			}
			else {
				return getStatusMessage(message: Str.obese, image: UIImage(named: "obese"))
			}
		case .activity:
			if value1 < 500 {
				return getStatusMessage(message: "Below Normal", image: UIImage(named: "obese"))
			} else if value1 < 5000 {
				return getStatusMessage(message: "On Track", image: UIImage(named: "heavy"))
			} else {
				return getStatusMessage(message: "On Track", image: UIImage(named: "healthy"))
			}
		case .bloodPressure:
			if value1 > 16.0 || value1 < 8.0 || value2 > 9.0 || value2 < 4.0 {
				return getStatusMessage(message: Str.high, image: UIImage(named: "obese"))
			} else if value1 > 14.0 || value1 < 9.0 || value2 > 8.0 || value2 < 5.0 {
				return getStatusMessage(message: Str.elevated, image: UIImage(named: "heavy"))
			} else {
				return getStatusMessage(message: Str.healthy, image: UIImage(named: "healthy"))
			}
		case .restingHR:
			if value1 < 30 || value1 > 90 {
				return getStatusMessage(message: "Not normal", image: UIImage(named: "heavy"))
			} else {
				return getStatusMessage(message: Str.healthy, image: UIImage(named: "healthy"))
			}
		case .heartRate:
			if value1 < 50 || value1 > 110 {
				return getStatusMessage(message: "Not normal", image: UIImage(named: "heavy"))
			} else {
				return getStatusMessage(message: Str.healthy, image: UIImage(named: "healthy"))
			}
		}
	}

	private func getStatusMessage(message: String, image: UIImage?) -> NSMutableAttributedString {
		let dailyString = NSMutableAttributedString(string: "")
		let dailyAttachment = NSTextAttachment()
		dailyAttachment.image = image
		let imageString = NSAttributedString(attachment: dailyAttachment)
		dailyString.append(imageString)
		dailyString.append(NSAttributedString(string: " "))
		dailyString.append(NSAttributedString(string: message))
		return dailyString
	}
}
