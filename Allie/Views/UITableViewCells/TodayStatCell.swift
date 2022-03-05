//
//  TodayStatCell.swift
//  Allie
//

import CareModel
import HealthKit
import UIKit

class TodayStatCell: UITableViewCell {
	@IBOutlet var typeImageView: UIImageView!
	@IBOutlet var typeLabel: UILabel!
	@IBOutlet var dateLabel: UILabel!
	@IBOutlet var valueLabel: UILabel!
	@IBOutlet var statusIndicatorView: UIView!
	@IBOutlet var statusLabel: UILabel!

	override func awakeFromNib() {
		super.awakeFromNib()
		statusIndicatorView.layer.cornerRadius = 5
		statusIndicatorView.isHidden = true
		statusLabel.isHidden = true
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		typeImageView.image = nil
		typeLabel.text = nil
		dateLabel.text = nil
		valueLabel.text = nil
		statusIndicatorView.isHidden = true
		statusLabel.text = nil
		statusLabel.isHidden = true
	}

	func setup(for quantityType: HealthKitQuantityType, with data: [Any]?) {
		typeLabel.attributedText = quantityType.displayTitle.attributedString(style: .semibold20, foregroundColor: quantityType.color)
		typeImageView.image = quantityType.image

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
		case .weight, .heartRate, .restingHeartRate, .bloodGlucose:
			let quantityValue = samples.first?.quantity.doubleValue(for: quantityType.hkUnit) ?? 0
			let value = NSMutableAttributedString(attributedString: String(Int(quantityValue)).attributedString(style: .semibold26, foregroundColor: .black))
			value.append(NSAttributedString(string: " "))
			value.append(quantityType.unitString.attributedString(style: .regular20, foregroundColor: .black))
			valueLabel.attributedText = value
			let status = quantityType.status(for: [quantityValue])
			statusLabel.attributedText = status.1.attributedString(style: .regular13, foregroundColor: .lightGrey)
			statusIndicatorView.backgroundColor = status.0
		case .bloodPressure where samples.count == 2:
			let pressureData = samples.sorted { sample1, sample2 -> Bool in
				let sample1Double = sample1.quantity.doubleValue(for: .millimeterOfMercury())
				let sample2Double = sample2.quantity.doubleValue(for: .millimeterOfMercury())
				return sample1Double > sample2Double
			}.map { Int($0.quantity.doubleValue(for: .millimeterOfMercury())) }
			guard let systolic = pressureData.first, let diastolic = pressureData.last else { return }
			let value = NSMutableAttributedString(attributedString: "\(systolic)/\(diastolic)".attributedString(style: .semibold26, foregroundColor: .black))
			value.append(NSAttributedString(string: " "))
			value.append(quantityType.unitString.attributedString(style: .regular20, foregroundColor: .black))
			valueLabel.attributedText = value
			let status = quantityType.status(for: [Double(systolic), Double(diastolic)])
			statusLabel.attributedText = status.1.attributedString(style: .regular13, foregroundColor: .lightGrey)
			statusIndicatorView.backgroundColor = status.0
		default:
			showNoData(for: quantityType)
		}
		dateLabel.attributedText = samples.first?.endDate.relationalString.attributedString(style: .regular13, foregroundColor: .lightGrey, letterSpacing: -0.16)
	}

	private func setup(for quantityType: HealthKitQuantityType, with statistics: [HKStatistics]) {
		guard quantityType == .activity else { return }
		let quantityValue = statistics.first?.sumQuantity()?.doubleValue(for: .count()) ?? 0
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		let number = NSNumber(value: Int(quantityValue))
		let numberString = formatter.string(from: number) ?? "\(Int(quantityValue))"
		let value = NSMutableAttributedString(attributedString: numberString.attributedString(style: .semibold26, foregroundColor: .black))
		value.append(NSAttributedString(string: " "))
		value.append(quantityType.unitString.attributedString(style: .regular20, foregroundColor: .black))
		valueLabel.attributedText = value
		dateLabel.attributedText = String.today.attributedString(style: .regular13, foregroundColor: .lightGrey, letterSpacing: -0.16)
		let status = quantityType.status(for: [quantityValue])
		statusLabel.attributedText = status.1.attributedString(style: .regular13, foregroundColor: .lightGrey)
		statusIndicatorView.backgroundColor = status.0
	}

	private func showNoData(for quantityType: HealthKitQuantityType) {
		if quantityType == .activity {
			let value = NSMutableAttributedString(attributedString: "0".attributedString(style: .semibold26, foregroundColor: .black))
			value.append(NSAttributedString(string: " "))
			value.append(quantityType.unitString.attributedString(style: .regular20, foregroundColor: .black))
			valueLabel.attributedText = value
			dateLabel.attributedText = String.today.attributedString(style: .regular13, foregroundColor: .lightGrey, letterSpacing: -0.16)
		} else {
			valueLabel.attributedText = String.noEntriesFoundToday.attributedString(style: .regular16, foregroundColor: .black)
			dateLabel.text = ""
		}
		statusLabel.text = ""
		statusIndicatorView.backgroundColor = .clear
	}
}
