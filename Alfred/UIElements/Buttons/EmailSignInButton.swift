//
//  emailSignInButton.swift
//  Alfred

import Foundation
import UIKit

class EmailSignInButton: UIButton {
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupView()
	}

	private func setupView() {
		titleEdgeInsets.left = 14
		contentEdgeInsets.top = 12
		contentEdgeInsets.bottom = 12
		layer.cornerRadius = 20.0
		layer.cornerCurve = .continuous
		layer.borderWidth = 1.0
		layer.borderColor = UIColor.grey.cgColor
	}

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		setupView()
	}
}
