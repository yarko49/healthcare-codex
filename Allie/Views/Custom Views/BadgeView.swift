//
//  BadgeView.swift
//  Allie
//
//  Created by Onseen on 3/4/22.
//

import SwiftUI
import UIKit

private class BadgeView: UIView {
	func setBackgroundColor(_ backgroundColor: UIColor?) {
		super.backgroundColor = backgroundColor
	}
}

public class BadgeHub: NSObject {
	var badgeCount: Int = 0 {
		didSet {
			countLabel?.text = "\(badgeCount)"
			checkZero()
			resizeToFitDigits()
		}
	}

	var maxCount: Int = 0
	var hubView: UIView?

	private var curOrderMagnitude: Int = 0
	private var countLabel: UILabel? {
		didSet {
			countLabel?.text = "\(badgeCount)"
			checkZero()
		}
	}

	private var redCircle: BadgeView!
	private var initialCenter = CGPoint.zero
	private var baseFrame = CGRect.zero
	private var initialFrame = CGRect.zero

	private enum Constants {
		static let notificHubDefaultDiameter: CGFloat = 20
		static let countMagnitudeAdaptionRation: CGFloat = 0.3

		static let popStartRatio: CGFloat = 0.85
		static let popOutRatio: CGFloat = 1.05
		static let popInRatio: CGFloat = 0.95

		static let blinkDuration: CGFloat = 0.1
		static let blinkAlpha: CGFloat = 0.1

		static let firstBumpDistance: CGFloat = 8.0
		static let bumpTimeSeconds: CGFloat = 0.13
		static let secondBumpDist: CGFloat = 4.0
		static let bumpTimeSeconds2: CGFloat = 0.1
	}

	public init(view: UIView) {
		super.init()

		self.maxCount = 100000
		setView(view, andCount: 0)
	}

	public convenience init?(barButtonItem: UIBarButtonItem) {
		if let value = barButtonItem.value(forKey: "viwe") as? UIView {
			self.init(view: value)
			scaleCircleSize(by: 0.7)
			moveCircleBy(xPos: -5.0, yPos: 0)
		} else if let value = barButtonItem.customView {
			self.init(view: value)
			scaleCircleSize(by: 0.7)
			moveCircleBy(xPos: -5.0, yPos: 0)
		} else {
			return nil
		}
	}

	public func setView(_ view: UIView?, andCount startCount: Int) {
		curOrderMagnitude = 0
		let frame: CGRect? = view?.frame

		redCircle = BadgeView()
		redCircle.isUserInteractionEnabled = false
		redCircle.backgroundColor = .red

		countLabel = UILabel(frame: redCircle.frame)
		countLabel?.isUserInteractionEnabled = false
		badgeCount = startCount
		countLabel?.textAlignment = .center
		countLabel?.textColor = .white
		countLabel?.backgroundColor = .clear

		setCircleAtFrame(CGRect(
			x: (frame?.size.width ?? 0) - ((Constants.notificHubDefaultDiameter) * 2 / 3),
			y: (-Constants.notificHubDefaultDiameter) / 3,
			width: CGFloat(Constants.notificHubDefaultDiameter),
			height: CGFloat(Constants.notificHubDefaultDiameter)
		)
		)
		view?.addSubview(redCircle)
		view?.addSubview(countLabel!)
		view?.bringSubviewToFront(redCircle)
		view?.bringSubviewToFront(countLabel!)
		hubView = view
		checkZero()
	}

	public func setCircleAtFrame(_ frame: CGRect) {
		redCircle.frame = frame
		initialCenter = CGPoint(
			x: frame.origin.x + frame.size.width / 2,
			y: frame.origin.y + frame.size.height / 2
		)
		baseFrame = frame
		initialFrame = frame
		countLabel?.frame = redCircle.frame
		redCircle.layer.cornerRadius = frame.size.height / 2
		countLabel?.font = .systemFont(ofSize: frame.size.width / 2)
	}

	public func setCircleColor(_ circleColor: UIColor?, label labelColor: UIColor?) {
		redCircle.backgroundColor = circleColor
		if let labelColor = labelColor {
			countLabel?.textColor = labelColor
		}
	}

	public func setCircleBorderColor(_ color: UIColor?, borderWidth width: CGFloat) {
		redCircle.layer.borderColor = color?.cgColor
		redCircle.layer.borderWidth = width
	}

	public func moveCircleBy(xPos: CGFloat, yPos: CGFloat) {
		var frame: CGRect = redCircle.frame
		frame.origin.x += xPos
		frame.origin.y += yPos
		setCircleAtFrame(frame)
	}

	public func scaleCircleSize(by scale: CGFloat) {
		let fr: CGRect = initialFrame
		let width: CGFloat = fr.size.width * scale
		let height: CGFloat = fr.size.height * scale
		let wdiff: CGFloat = (fr.size.width - width) / 2
		let hdiff: CGFloat = (fr.size.height - height) / 2

		let frame = CGRect(x: fr.origin.x + wdiff,
		                   y: fr.origin.y + hdiff,
		                   width: width, height: height)
		setCircleAtFrame(frame)
	}

	public func increment() {
		increment(by: 1)
	}

	public func increment(by amount: Int) {
		badgeCount += amount
	}

	public func decrement() {
		decrement(by: 1)
	}

	public func decrement(by amount: Int) {
		if amount >= badgeCount {
			badgeCount = 0
			return
		}
		badgeCount -= amount
		checkZero()
	}

	public func hide() {
		redCircle.isHidden = true
		countLabel?.isHidden = true
	}

	public func show() {
		redCircle.isHidden = false
		countLabel?.isHidden = false
	}

	public func hideCount() {
		redCircle.isHidden = true
	}

	public func showCount() {
		checkZero()
	}

	public func getCurrentCount() -> Int {
		badgeCount
	}

	public func setMaxCount(to count: Int) {
		maxCount = count
	}

	public func setCount(_ newCount: Int) {
		badgeCount = newCount
		let labelText = badgeCount > maxCount ? "\(maxCount)+" : "\(badgeCount)"
		countLabel?.text = labelText
		checkZero()
	}

	public func setCountLabelFont(_ font: UIFont?) {
		countLabel?.font = font
	}

	public func getCountLabelFont() -> UIFont? {
		countLabel?.font
	}

	public func bumpCenterY(yVal: CGFloat) {
		var center: CGPoint = redCircle.center
		center.y = initialCenter.y - yVal
		redCircle.center = center
		countLabel?.center = center
	}

	public func setAlpha(alpha: CGFloat) {
		redCircle.alpha = alpha
		countLabel?.alpha = alpha
	}

	public func checkZero() {
		if badgeCount > 0 {
			redCircle.isHidden = false
			countLabel?.isHidden = false
		} else {
			redCircle.isHidden = true
			countLabel?.isHidden = true
		}
	}

	func resizeToFitDigits() {
		guard badgeCount > 0 else { return }
		var orderOfMagnitude = Int(log10(Double(badgeCount)))
		orderOfMagnitude = (orderOfMagnitude >= 2) ? orderOfMagnitude : 1
		var frame: CGRect = initialFrame
		frame.size.width = CGFloat(initialFrame.size.width * (1 + 0.3 * CGFloat(orderOfMagnitude - 1)))
		frame.origin.x = initialFrame.origin.x - (frame.size.width - initialFrame.size.width) / 2

		redCircle.frame = frame
		initialCenter = CGPoint(
			x: frame.origin.x + frame.size.width / 2,
			y: frame.origin.y + frame.size.height / 2
		)
		baseFrame = frame
		countLabel?.frame = redCircle.frame
		curOrderMagnitude = orderOfMagnitude
	}
}
