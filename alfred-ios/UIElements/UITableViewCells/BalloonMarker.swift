
//  BalloonMarker.swift
//  ChartsDemo

import Charts
import Foundation
import UIKit

open class BalloonMarker: MarkerImage {
	@objc open var color: UIColor
	@objc open var arrowSize = CGSize(width: 5, height: 40)
	@objc open var font: UIFont
	@objc open var textColor: UIColor
	@objc open var insets: UIEdgeInsets
	@objc open var minimumSize = CGSize()
	@objc open var lineChartView: LineChartView!
	@objc open var lineData: LineChartDataSet!

	fileprivate var date = DateFormatter()
	fileprivate var label: NSMutableAttributedString?
	fileprivate var _labelSize = CGSize()

	@objc public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets) {
		self.color = color
		self.textColor = textColor
		self.insets = insets
		self.font = font
		super.init()
	}

	override open func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
		var offset = self.offset
		var size = self.size

		if size.width == 0.0, image != nil {
			size.width = image!.size.width
		}
		if size.height == 0.0, image != nil {
			size.height = image!.size.height
		}

		let width = size.width
		let height = size.height
		let padding: CGFloat = 40.0

		var origin = point
		origin.x -= width / 2
		origin.y -= height

		if origin.x + offset.x < 0.0 {
			offset.x = -origin.x + padding
		}
		else if let chart = lineChartView,
		        origin.x + width + offset.x > chart.bounds.size.width
		{
			offset.x = chart.bounds.size.width - origin.x - width - padding
		}

		if origin.y + offset.y < 0 {
			offset.y = height + padding
		}
		else if let chart = lineChartView,
		        origin.y + height + offset.y > chart.bounds.size.height
		{
			offset.y = chart.bounds.size.height - origin.y - height - padding
		}

		return offset
	}

	override open func draw(context context1: CGContext, point: CGPoint) {
		guard let label = label else { return }

		let offset = offsetForDrawing(atPoint: point)
		let size = self.size

		var rect = CGRect(
			origin: CGPoint(
				x: point.x + offset.x,
				y: point.y + offset.y
			),
			size: size
		)
		rect.origin.x -= size.width / 2.0
		rect.origin.y -= size.height

		if offset.y > 0 {
			rect.origin.y -= size.height - arrowSize.height
		} else {
			rect.origin.y -= size.height + arrowSize.height
		}

		context1.saveGState()

		let clipPath: CGPath = UIBezierPath(roundedRect: rect, cornerRadius: 3.0).cgPath

		context1.setFillColor(color.cgColor)

		if offset.y > 0 {
			context1.beginPath()

			context1.move(to: CGPoint(
				x: rect.origin.x,
				y: rect.origin.y + arrowSize.height
			))

			context1.addLine(to: CGPoint(
				x: rect.origin.x + (rect.size.width / 2.0),
				y: rect.origin.y + arrowSize.height
			))

			context1.addLine(to: CGPoint(
				x: point.x,
				y: point.y
			))

			context1.addLine(to: CGPoint(
				x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
				y: rect.origin.y + arrowSize.height
			))

			context1.addLine(to: CGPoint(
				x: rect.origin.x + rect.size.width,
				y: rect.origin.y + arrowSize.height
			))

			context1.addLine(to: CGPoint(
				x: rect.origin.x + rect.size.width,
				y: rect.origin.y + rect.size.height
			))

			context1.addLine(to: CGPoint(
				x: rect.origin.x,
				y: rect.origin.y + rect.size.height
			))

			context1.addLine(to: CGPoint(
				x: rect.origin.x,
				y: rect.origin.y + arrowSize.height
			))

			context1.addPath(clipPath)

			context1.fillPath()
			context1.strokePath()
		}
		else {
			context1.beginPath()

			context1.move(to: CGPoint(
				x: rect.origin.x,
				y: rect.origin.y
			))

			context1.addLine(to: CGPoint(
				x: rect.origin.x + rect.size.width,
				y: rect.origin.y
			))

			context1.addLine(to: CGPoint(
				x: rect.origin.x + rect.size.width,
				y: rect.origin.y + rect.size.height - arrowSize.height
			))

			context1.addLine(to: CGPoint(
				x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
				y: rect.origin.y + rect.size.height - arrowSize.height
			))

			context1.addLine(to: CGPoint(
				x: point.x,
				y: point.y
			))

			context1.addLine(to: CGPoint(
				x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
				y: rect.origin.y + rect.size.height - arrowSize.height
			))
			glLineWidth(3.0)

			context1.addLine(to: CGPoint(
				x: rect.origin.x,
				y: rect.origin.y + rect.size.height - arrowSize.height
			))

			context1.addLine(to: CGPoint(
				x: rect.origin.x,
				y: rect.origin.y
			))

			context1.addPath(clipPath)
			context1.fillPath()
			context1.strokePath()
		}

		if offset.y > 0 {
			rect.origin.y += insets.top + arrowSize.height
		} else {
			rect.origin.y += insets.top
		}

		rect.size.height -= insets.top + insets.bottom

		UIGraphicsPushContext(context1)
		label.draw(in: rect)
		UIGraphicsPopContext()
		context1.restoreGState()
	}

	override open func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center

		let boldFontAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.paragraphStyle: paragraphStyle]
		let normalFontAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11), NSAttributedString.Key.paragraphStyle: paragraphStyle]

		let combination = NSMutableAttributedString()

		let partOne = NSMutableAttributedString(string: String(entry.y), attributes: boldFontAttributes)
		let partTwo = NSMutableAttributedString(string: "lbs", attributes: normalFontAttributes)
		let partThree = NSMutableAttributedString(string: " ", attributes: normalFontAttributes)
		let partFour = NSMutableAttributedString(string: "\n", attributes: boldFontAttributes)
		let partFive = NSMutableAttributedString(string: "13/7/20", attributes: normalFontAttributes)

		combination.append(partOne)
		combination.append(partTwo)
		combination.append(partThree)
		combination.append(partFour)
		combination.append(partFive)

		setLabel(combination)
	}

	@objc open func setLabel(_ newLabel: NSMutableAttributedString) {
		label = newLabel
		_labelSize = label?.size() ?? CGSize.zero
		var size = CGSize()
		size.width = _labelSize.width + insets.left + insets.right
		size.height = _labelSize.height + insets.top + insets.bottom
		size.width = max(minimumSize.width, size.width)
		size.height = max(minimumSize.height, size.height)
		self.size = size
	}
}
