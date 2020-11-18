//
//  TodayStatCell.swift
//  alfred-ios
//
//  Created by John Spiropoulos on 10/11/20.
//

import HealthKit
import UIKit

class TodayStatCell: UITableViewCell {
	@IBOutlet var typeIV: UIImageView!
	@IBOutlet var typeLbl: UILabel!
	@IBOutlet var dateLbl: UILabel!
	@IBOutlet var valueLbl: UILabel!
	@IBOutlet var statusIndicatorView: UIView!
	@IBOutlet var statusLbl: UILabel!

	override func awakeFromNib() {
		super.awakeFromNib()
		statusIndicatorView.layer.cornerRadius = 5
	}

	func setup(for quantityType: HealthKitQuantityType, with data: [Any]?) {
		typeLbl.attributedText = quantityType.rawValue.with(style: .semibold20, andColor: quantityType.getColor())
		typeIV.image = quantityType.getImage()

		if let samples = data as? [HKQuantitySample] {
			setup(for: quantityType, with: samples)
		} else if let statistics = data as? [HKStatistics] {
			setup(for: quantityType, with: statistics)
		} else {
			showNoData(for: quantityType)
		}
	}

	private func setup(for quantityType: HealthKitQuantityType, with samples: [HKQuantitySample]) {
		switch quantityType {
		case .weight, .heartRate, .restingHR:
			let quantityValue = samples.first?.quantity.doubleValue(for: quantityType.hkUnit) ?? 0
			let value = NSMutableAttributedString(attributedString: String(Int(quantityValue)).with(style: .semibold26, andColor: .black))
			value.append(NSAttributedString(string: " "))
			value.append(quantityType.getUnit().with(style: .regular20, andColor: .black))
			valueLbl.attributedText = value
			let status = quantityType.getStatus(for: [quantityValue])
			statusLbl.attributedText = status.1.with(style: .regular13, andColor: .lightGrey)
			statusIndicatorView.backgroundColor = status.0
		case .bloodPressure where samples.count == 2:
			let pressureData = samples.sorted { (sample1, sample2) -> Bool in
				let sample1Double = sample1.quantity.doubleValue(for: .millimeterOfMercury())
				let sample2Double = sample2.quantity.doubleValue(for: .millimeterOfMercury())
				return sample1Double > sample2Double
			}.map { Int($0.quantity.doubleValue(for: .millimeterOfMercury())) }
			guard let systolic = pressureData.first, let diastolic = pressureData.last else { return }
			let value = NSMutableAttributedString(attributedString: "\(systolic)/\(diastolic)".with(style: .semibold26, andColor: .black))
			value.append(NSAttributedString(string: " "))
			value.append(quantityType.getUnit().with(style: .regular20, andColor: .black))
			valueLbl.attributedText = value
			let status = quantityType.getStatus(for: [Double(systolic), Double(diastolic)])
			statusLbl.attributedText = status.1.with(style: .regular13, andColor: .lightGrey)
			statusIndicatorView.backgroundColor = status.0
		default:
			showNoData(for: quantityType)
		}
		dateLbl.attributedText = samples.first?.endDate.relationalString.with(style: .regular13, andColor: .lightGrey, andLetterSpacing: -0.16)
	}

	private func setup(for quantityType: HealthKitQuantityType, with statistics: [HKStatistics]) {
		guard quantityType == .activity else { return }
		let quantityValue = statistics.first?.sumQuantity()?.doubleValue(for: .count()) ?? 0
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		let number = NSNumber(integerLiteral: Int(quantityValue))
		let numberString = formatter.string(from: number) ?? "\(Int(quantityValue))"
		let value = NSMutableAttributedString(attributedString: numberString.with(style: .semibold26, andColor: .black))
		value.append(NSAttributedString(string: " "))
		value.append(quantityType.getUnit().with(style: .regular20, andColor: .black))
		valueLbl.attributedText = value
		dateLbl.attributedText = Str.today.with(style: .regular13, andColor: .lightGrey, andLetterSpacing: -0.16)
		let status = quantityType.getStatus(for: [quantityValue])
		statusLbl.attributedText = status.1.with(style: .regular13, andColor: .lightGrey)
		statusIndicatorView.backgroundColor = status.0
	}

	private func showNoData(for quantityType: HealthKitQuantityType) {
		if quantityType == .activity {
			let value = NSMutableAttributedString(attributedString: "0".with(style: .semibold26, andColor: .black))
			value.append(NSAttributedString(string: " "))
			value.append(quantityType.getUnit().with(style: .regular20, andColor: .black))
			valueLbl.attributedText = value
			dateLbl.attributedText = Str.today.with(style: .regular13, andColor: .lightGrey, andLetterSpacing: -0.16)
		} else {
			valueLbl.attributedText = Str.noEntriesFoundToday.with(style: .regular16, andColor: .black)
			dateLbl.text = ""
		}
		statusLbl.text = ""
		statusIndicatorView.backgroundColor = .clear
	}
}
