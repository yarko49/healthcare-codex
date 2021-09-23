//
//  InsulinLogItemButton.swift
//  Allie
//
//  Created by Waqar Malik on 5/19/21.
//

import CareKit
import CareKitUI
import UIKit

class GeneralizedLogItem: OCKAnimatedButton<OCKStackView> {
	private enum Constants {
		static let spacing: CGFloat = 3
	}

	// MARK: Properties

	public let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "icon-lock-fill")
		imageView.preferredSymbolConfiguration = .init(textStyle: .caption1)
		imageView.widthAnchor.constraint(equalToConstant: 15.0).isActive = true
		imageView.heightAnchor.constraint(equalToConstant: 15.0).isActive = true
		return imageView
	}()

	public let valueLabel: OCKLabel = {
		let label = OCKLabel(textStyle: .caption1, weight: .regular)
		return label
	}()

	public let timeLabel: OCKLabel = {
		let label = OCKLabel(textStyle: .caption1, weight: .regular)
		return label
	}()

	public let contextLabel: OCKLabel = {
		let label = OCKLabel(textStyle: .caption1, weight: .regular)
		return label
	}()

	/// Holds the main content in the button.
	public let contentStackView: OCKStackView = {
		let stackView = OCKStackView()
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.distribution = .fill
		stackView.spacing = 4.0
		return stackView
	}()

	// MARK: - Life cycle

	public init() {
		super.init(contentView: contentStackView, handlesSelection: false)
		setup()
	}

	public required init?(coder: NSCoder) {
		super.init(contentView: contentStackView, handlesSelection: false)
		setup()
	}

	// MARK: Methods

	private func setup() {
		addSubviews()
		constrainSubviews()
		styleSubviews()
	}

	private func styleSubviews() {
		applyTintColor()
	}

	private func addSubviews() {
		addSubview(contentStackView)
		[valueLabel, timeLabel, contextLabel, imageView].forEach { contentStackView.addArrangedSubview($0) }
	}

	private func constrainSubviews() {
		[contentStackView].forEach { $0?.translatesAutoresizingMaskIntoConstraints = false }
		valueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		timeLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		// imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		NSLayoutConstraint.activate(contentStackView.constraints(equalTo: self, directions: [.horizontal]) +
			contentStackView.constraints(equalTo: layoutMarginsGuide, directions: [.vertical]))
	}

	private func applyTintColor() {
		contextLabel.textColor = tintColor
	}

	override open func styleDidChange() {
		super.styleDidChange()
		let style = self.style()
		timeLabel.textColor = style.color.label
		contentStackView.setCustomSpacing(style.dimension.directionalInsets1.top, after: contextLabel)
		directionalLayoutMargins = style.dimension.directionalInsets1
	}

	override open func tintColorDidChange() {
		super.tintColorDidChange()
		applyTintColor()
	}
}
