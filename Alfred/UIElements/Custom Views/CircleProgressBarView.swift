//
//  CardProgressBarView.swift
//  Alfred
//

import Foundation
import UIKit

class CircleProgressBarView: UIView {
	@IBOutlet var contentView: UIView!
	@IBOutlet var iconImageView: UIImageView!

	// MARK: - IBOutlets

	private var progressShapeLayer = CAShapeLayer()
	private var trackShapeLayer = CAShapeLayer()

	var progressClr = UIColor.black {
		didSet {
			progressShapeLayer.strokeColor = progressClr.cgColor
		}
	}

	var trackClr = UIColor.black {
		didSet {
			trackShapeLayer.strokeColor = trackClr.cgColor
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
		Bundle.main.loadNibNamed(Self.nibName, owner: self, options: nil)
		contentView.fixInView(self)
	}

	func setup(color: String, opacity: Float, icon: IconType) {
		switch icon {
		case .scale:
			iconImageView.image = UIImage(named: "weightCardIcon")
		case .activity:
			iconImageView.image = UIImage(named: "activityCardIcon")
		case .heart:
			iconImageView.image = UIImage(named: "bloodPressureCardIcon")
		case .questionnaire:
			iconImageView.image = UIImage(named: "surveyCardIcon")
		case .heartRate:
			iconImageView.image = UIImage(named: "heartRateCardIcon")
		case .heartRateResting:
			iconImageView.image = UIImage(named: "restingHeartRateCardIcon")
		case .other:
			iconImageView.image = UIImage(named: "defaultCardIcon")
		}

		if let color = UIColor(hex: color) {
			progressClr = color
		}

		trackClr = progressClr.withAlphaComponent(CGFloat(opacity) / 4.0)
		makeCircularPath()

		backgroundColor = UIColor.white.withAlphaComponent(CGFloat(opacity) / 2.0)
	}

	private func makeCircularPath() {
		backgroundColor = UIColor.clear
		layer.cornerRadius = frame.size.width / 2
		let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2, y: frame.size.height / 2), radius: (frame.size.width - 1.5) / 2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
		trackShapeLayer.path = circlePath.cgPath
		trackShapeLayer.fillColor = UIColor.clear.cgColor
		trackShapeLayer.strokeColor = trackClr.cgColor
		trackShapeLayer.lineWidth = 3.0
		trackShapeLayer.strokeEnd = 1.0
		layer.addSublayer(trackShapeLayer)
		progressShapeLayer.path = circlePath.cgPath
		progressShapeLayer.fillColor = UIColor.clear.cgColor
		progressShapeLayer.strokeColor = progressClr.cgColor
		progressShapeLayer.lineWidth = 3.0
		progressShapeLayer.strokeEnd = 0.0
		layer.addSublayer(progressShapeLayer)
	}

	func setProgressWithAnimation(value: Float) {
		let animation = CABasicAnimation(keyPath: "strokeEnd")
		animation.duration = 1.0
		animation.fromValue = 0
		animation.toValue = value
		animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
		progressShapeLayer.strokeEnd = CGFloat(value)
		progressShapeLayer.add(animation, forKey: "animateprogress")
	}
}
