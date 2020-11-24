
//  BalloonMarker.swift
//  ChartsDemo

import Charts
import Foundation
import UIKit

class BalloonMarker: MarkerImage {
	private var color: UIColor
	private var arrowSize = CGSize(width: 2, height: 60)
	private var font: UIFont
	private var textColor: UIColor
	private var insets: UIEdgeInsets
	private var unit: String
	private var numberFormatter: NumberFormatter
	private var intervalType: ChartIntervalType
	private var circleSize = CGSize(width: 5, height: 5)
	private var month: Int?
	private var year: Int?

	private var dateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.timeStyle = .none
		df.dateStyle = .short
		return df
	}()

	private var balloonText: NSMutableAttributedString?
	private var balloonSize: CGSize {
		let textSize = balloonText?.size() ?? CGSize.zero
		return CGSize(width: textSize.width + insets.right + insets.left, height: textSize.height + insets.top + insets.bottom)
	}

	init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets, unit: String, numberFormatter: NumberFormatter, intervalType: ChartIntervalType) {
		self.color = color
		self.textColor = textColor
		self.insets = insets
		self.font = font
		self.unit = unit
		self.numberFormatter = numberFormatter
		self.intervalType = intervalType
		super.init()
	}

	override open func draw(context context1: CGContext, point: CGPoint) {
		guard let balloonText = balloonText else { return }
		let combinedSize = CGSize(width: balloonSize.width, height: balloonSize.height + arrowSize.height + (circleSize.height / 2))

		let onTop = combinedSize.height < point.y

		var ballonY: CGFloat {
			if onTop {
				return point.y - (circleSize.height / 2) - arrowSize.height - balloonSize.height
			} else {
				return point.y + (circleSize.height / 2) + arrowSize.height
			}
		}

		var balloonX: CGFloat {
			let initialX = point.x - (balloonSize.width / 2)
			let chartWidth = chartView?.bounds.size.width ?? UIScreen.main.bounds.width
			if initialX < 0 {
				return 0
			} else if initialX + balloonSize.width > chartWidth {
				return chartWidth - balloonSize.width
			}
			return initialX
		}
		var arrowY: CGFloat {
			if onTop {
				return point.y - (circleSize.height / 2) - arrowSize.height
			} else {
				return point.y + (circleSize.height / 2)
			}
		}
		let balloonRect = CGRect(x: balloonX, y: ballonY, width: balloonSize.width, height: balloonSize.height)
		let arrowRect = CGRect(x: point.x - (arrowSize.width / 2), y: arrowY, width: arrowSize.width, height: arrowSize.height)
		let circleRect = CGRect(x: point.x - (circleSize.width / 2), y: point.y - (circleSize.height / 2), width: circleSize.width, height: circleSize.height)

		if combinedSize.height > point.y {}

		context1.saveGState()
		context1.setFillColor(color.cgColor)
		context1.beginPath()

		let balloonPath = UIBezierPath(roundedRect: balloonRect, cornerRadius: 3).cgPath
		context1.addPath(balloonPath)
		context1.addRect(arrowRect)
		context1.addEllipse(in: circleRect)
		context1.fillPath()
		context1.strokePath()
		UIGraphicsPushContext(context1)
		balloonText.draw(in: balloonRect)
		UIGraphicsPopContext()
		context1.restoreGState()
	}

	override open func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center

		let boldFontAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.paragraphStyle: paragraphStyle]
		let normalFontAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11), NSAttributedString.Key.paragraphStyle: paragraphStyle]

		let combination = NSMutableAttributedString()
		let numberString = numberFormatter.string(from: NSNumber(integerLiteral: Int(entry.y)))
		let partOne = NSMutableAttributedString(string: numberString ?? "", attributes: boldFontAttributes)
		let partTwo = NSMutableAttributedString(string: " ", attributes: normalFontAttributes)
		let partThree = NSMutableAttributedString(string: unit, attributes: normalFontAttributes)
		let partFour = NSMutableAttributedString(string: "\n", attributes: normalFontAttributes)
		var dateString = ""
		switch intervalType {
		case .week:
			dateString = dateFormatter.string(from: Date(timeIntervalSinceReferenceDate: entry.x))

		case .month(let components):
			var fullComponents = components
			fullComponents.day = Int(entry.x)
			let date = Calendar.current.date(from: fullComponents) ?? Date()
			dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yyyy", options: 0, locale: Locale.current)
			dateString = dateFormatter.string(from: date)
		case .year(let components):
			var fullComponents = components
			fullComponents.month = Int(entry.x)
			let date = Calendar.current.date(from: fullComponents) ?? Date()
			dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMM yyyy", options: 0, locale: Locale.current)
			dateString = dateFormatter.string(from: date)
		default:
			break
		}

		let partFive = NSMutableAttributedString(string: dateString, attributes: normalFontAttributes)
		combination.append(partOne)
		combination.append(partTwo)
		combination.append(partThree)
		combination.append(partFour)
		combination.append(partFive)

		balloonText = combination
	}
}
