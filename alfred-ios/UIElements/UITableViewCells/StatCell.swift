//
//  TodayStatCell.swift
//  alfred-ios
//

import Charts
import HealthKit
import UIKit

class StatCell: UITableViewCell {
	@IBOutlet var typeIV: UIImageView!
	@IBOutlet var typeLbl: UILabel!
	@IBOutlet var avgLbl: UILabel!
	@IBOutlet var avgValueLbl: UILabel!
	@IBOutlet var hilowContainerView: UIView!
	@IBOutlet var highLbl: UILabel!
	@IBOutlet var highValueLbl: UILabel!
	@IBOutlet var lowLbl: UILabel!
	@IBOutlet var lowValueLbl: UILabel!
	@IBOutlet var chartContainerView: UIView!
	@IBOutlet var expandColapseBtn: UIButton!

	var highLowWithDataWidthConstraint: NSLayoutConstraint?
	var highLowWNoDataWidthConstraint: NSLayoutConstraint?

	var expandColapseAction: ((Bool) -> Void)?

	private let lineChartView: ProfileChartView = {
		let chartView = ProfileChartView()
		chartView.translatesAutoresizingMaskIntoConstraints = false
		return chartView
	}()

	override func awakeFromNib() {
		super.awakeFromNib()
		highLowWithDataWidthConstraint = hilowContainerView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.45)
		highLowWNoDataWidthConstraint = hilowContainerView.widthAnchor.constraint(equalToConstant: 0)
		chartContainerView.backgroundColor = UIColor.chartColor
		chartContainerView.addSubview(lineChartView)
		lineChartView.topAnchor.constraint(equalTo: chartContainerView.topAnchor, constant: 12).isActive = true
		lineChartView.leadingAnchor.constraint(equalTo: chartContainerView.leadingAnchor, constant: 0).isActive = true
		lineChartView.trailingAnchor.constraint(equalTo: chartContainerView.trailingAnchor, constant: -10).isActive = true
		lineChartView.bottomAnchor.constraint(equalTo: chartContainerView.bottomAnchor).isActive = true
		let heightAnchor = lineChartView.heightAnchor.constraint(equalTo: lineChartView.widthAnchor, multiplier: 0.7)
		heightAnchor.priority = UILayoutPriority(rawValue: 999)
		heightAnchor.isActive = true
	}

	func setup(for quantityType: HealthKitQuantityType, with data: [StatModel]?, intervalType: HealthStatsDateIntervalType, expanded: Bool) {
		chartContainerView.alpha = expanded ? 1 : 0
		chartContainerView.isHidden = !expanded
		expandColapseBtn.isSelected = expanded
		typeLbl.attributedText = quantityType.rawValue.with(style: .semibold20, andColor: quantityType.getColor())
		typeIV.image = quantityType.getImage()
		var avgString: String {
			switch intervalType {
			case .daily: return ""
			case .weekly: return quantityType != .activity ? Str.weeklyAvg : Str.weekTotal
			case .monthly: return quantityType != .activity ? Str.monthlyAvg : Str.monthTotal
			case .yearly: return quantityType != .activity ? Str.yearlyAvg : Str.yearTotal
			}
		}

		guard let data = data, let statData = data.first else {
			showNoData(for: quantityType)
			return
		}
		[highValueLbl, highLbl, lowValueLbl, lowLbl].forEach { $0?.isHidden = false }
		avgLbl.attributedText = avgString.with(style: .regular15, andColor: .lightGrey)
		highLbl.attributedText = Str.high.with(style: .regular15, andColor: .lightGrey)
		lowLbl.attributedText = Str.low.with(style: .regular15, andColor: .lightGrey)
		highLowWNoDataWidthConstraint?.isActive = false
		highLowWithDataWidthConstraint?.isActive = true
		switch quantityType {
		case .weight, .heartRate, .restingHR, .activity:
			let intValues = statData.dataPoints.compactMap { $0.value?.doubleValue(for: quantityType.hkUnit) }.map { Int($0) }
			guard !intValues.isEmpty else {
				showNoData(for: quantityType)
				return
			}
			let valuesCount = !intValues.isEmpty ? intValues.count : 1
			let averageValue = quantityType != .activity ? intValues.sum() / valuesCount : intValues.sum()
			let formatter = NumberFormatter()
			formatter.numberStyle = .decimal
			let avgNumber = NSNumber(integerLiteral: Int(averageValue))
			let avgNumberString = formatter.string(from: avgNumber) ?? "\(Int(averageValue))"
			let value = NSMutableAttributedString(attributedString: avgNumberString.with(style: .semibold26, andColor: .black))
			value.append(NSAttributedString(string: " "))
			value.append(quantityType.getUnit().with(style: .regular20, andColor: .black))
			avgValueLbl.attributedText = value

			let hiValue = intValues.max() ?? averageValue
			let hiNumber = NSNumber(integerLiteral: Int(hiValue))
			let hiNumberString = formatter.string(from: hiNumber) ?? "\(Int(hiValue))"
			highValueLbl.attributedText = "\(hiNumberString)".with(style: .regular16, andColor: .black)

			let lowValue = intValues.min() ?? averageValue
			let lowNumber = NSNumber(integerLiteral: lowValue)
			let lowNumberString = formatter.string(from: lowNumber) ?? "\(Int(lowValue))"
			lowValueLbl.attributedText = lowNumberString.with(style: .regular16, andColor: .black)
			lineChartView.setup(with: data, quantityType: quantityType, intervalType: intervalType)
		case .bloodPressure where data.count == 2:
			let sortedData = data.sorted { (data1, data2) -> Bool in
				let valueSum1 = data1.dataPoints.map { Int($0.value?.doubleValue(for: .millimeterOfMercury()) ?? 0) }.sum()
				let valueSum2 = data2.dataPoints.map { Int($0.value?.doubleValue(for: .millimeterOfMercury()) ?? 0) }.sum()
				return valueSum1 > valueSum2
			}
			guard let systolics = sortedData.first, let diastolics = sortedData.last else { return }
			var datapointCouples: [(systolic: StatsDataPoint, diastolic: StatsDataPoint)] = []
			systolics.dataPoints.enumerated().forEach { offset, systolicDataPoint in
				if diastolics.dataPoints.count > offset {
					guard systolicDataPoint.value != nil, diastolics.dataPoints[offset].value != nil else { return }
					datapointCouples.append((systolic: systolicDataPoint, diastolic: diastolics.dataPoints[offset]))
				}
			}
			let mappedSystolicsValues = datapointCouples.compactMap { $0.systolic.value?.doubleValue(for: .millimeterOfMercury()) }
			let mappedDiastolicsValues = datapointCouples.map { $0.diastolic.value?.doubleValue(for: .millimeterOfMercury()) ?? 0 }
			guard !mappedSystolicsValues.isEmpty, !mappedDiastolicsValues.isEmpty else {
				showNoData(for: quantityType)
				return
			}

			let avgSystolic = mappedSystolicsValues.map { Int($0) }.sum() / mappedSystolicsValues.count
			let avgDiastolic = mappedDiastolicsValues.map { Int($0) }.sum() / mappedDiastolicsValues.count

			let value = NSMutableAttributedString(attributedString: String("\(Int(avgSystolic))/\(Int(avgDiastolic))").with(style: .semibold26, andColor: .black))
			value.append(NSAttributedString(string: " "))
			value.append(quantityType.getUnit().with(style: .regular20, andColor: .black))
			avgValueLbl.attributedText = value

			let combinedPressure = zip(mappedSystolicsValues, mappedDiastolicsValues).map(+)
			let maxEntry = combinedPressure.enumerated().max(by: { a, b in
				a.element < b.element
			})

			let minEntry = combinedPressure.enumerated().min(by: { a, b in
				a.element < b.element
			})
			guard let maxIndex = maxEntry?.offset, let minIndex = minEntry?.offset, datapointCouples.count > maxIndex, datapointCouples.count > minIndex else { return }
			let maxPressure = datapointCouples[maxIndex]
			let maxDiastolicInt = Int(maxPressure.diastolic.value?.doubleValue(for: .millimeterOfMercury()) ?? 0)
			let maxSystolicInt = Int(maxPressure.systolic.value?.doubleValue(for: .millimeterOfMercury()) ?? 0)
			highValueLbl.attributedText = "\(maxSystolicInt)/\(maxDiastolicInt)".with(style: .regular16, andColor: .black)

			let minPressure = datapointCouples[minIndex]
			let minDiastolicInt = Int(minPressure.diastolic.value?.doubleValue(for: .millimeterOfMercury()) ?? 0)
			let minSystolicInt = Int(minPressure.systolic.value?.doubleValue(for: .millimeterOfMercury()) ?? 0)
			lowValueLbl.attributedText = "\(minSystolicInt)/\(minDiastolicInt)".with(style: .regular16, andColor: .black)
			lineChartView.setup(with: data, quantityType: quantityType, intervalType: intervalType)
		default:
			showNoData(for: quantityType)
		}
	}

	private func showNoData(for quantityType: HealthKitQuantityType) {
		[highValueLbl, highLbl, lowValueLbl, lowLbl].forEach { $0?.isHidden = true }
		if quantityType == .activity {
			let value = NSMutableAttributedString(attributedString: "0".with(style: .semibold26, andColor: .black))
			value.append(NSAttributedString(string: " "))
			value.append(quantityType.getUnit().with(style: .regular20, andColor: .black))
			avgValueLbl.attributedText = value

		} else {
			avgValueLbl.attributedText = Str.noEntriesFoundRange.with(style: .regular16, andColor: .black)
		}
		avgLbl.text = ""
		highLbl.text = ""
		lowLbl.text = ""
		highLowWithDataWidthConstraint?.isActive = false
		highLowWNoDataWidthConstraint?.isActive = true
		lineChartView.data = nil
	}

	@IBAction func expandColapseTapped(_ sender: UIButton) {
		expandColapseAction?(!sender.isSelected)
	}
}
