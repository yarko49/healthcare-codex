//
//  GradientView.swift
//  Allie
//
//  Created by Waqar Malik on 5/15/21.
//

import UIKit

class GradientView: UIView {
	private var gradient: CAGradientLayer {
		guard let layer = layer as? CAGradientLayer else {
			fatalError("Unsupported type")
		}
		return layer
	}

	override class var layerClass: AnyClass {
		CAGradientLayer.self
	}

	var colors: [UIColor]? {
		get {
			gradient.colors?.compactMap { value in
				// swiftlint:disable:next force_cast
				UIColor(cgColor: value as! CGColor)
			}
		}
		set {
			gradient.colors = newValue?.map { color in
				color.cgColor
			}
		}
	}

	var locations: [Double]? {
		get {
			gradient.locations?.map { number in
				number.doubleValue
			}
		}
		set {
			gradient.locations = newValue?.map { value in
				NSNumber(value: value)
			}
		}
	}

	var startPoint: CGPoint {
		get {
			gradient.startPoint
		}
		set {
			gradient.startPoint = newValue
		}
	}

	var endPoint: CGPoint {
		get {
			gradient.endPoint
		}
		set {
			gradient.endPoint = newValue
		}
	}

	var type: CAGradientLayerType {
		get {
			gradient.type
		}
		set {
			gradient.type = newValue
		}
	}
}
