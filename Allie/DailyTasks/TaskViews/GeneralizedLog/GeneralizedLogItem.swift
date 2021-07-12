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
		return imageView
	}()

	public let titleLabel: OCKLabel = {
		let label = OCKLabel(textStyle: .caption1, weight: .regular)
		return label
	}()

	public let detailLabel: OCKLabel = {
		let label = OCKLabel(textStyle: .caption1, weight: .regular)
		return label
	}()

	/// Holds the main content in the button.
	public let contentStackView: OCKStackView = {
		let stackView = OCKStackView()
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.distribution = .fill
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
		[detailLabel, titleLabel, imageView].forEach { contentStackView.addArrangedSubview($0) }
	}

	private func constrainSubviews() {
		[contentStackView].forEach { $0?.translatesAutoresizingMaskIntoConstraints = false }
		detailLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		NSLayoutConstraint.activate(
			contentStackView.constraints(equalTo: self, directions: [.horizontal]) +
				contentStackView.constraints(equalTo: layoutMarginsGuide, directions: [.vertical])
		)
		imageView.isHidden = true
	}

	private func applyTintColor() {
		detailLabel.textColor = tintColor
	}

	override open func styleDidChange() {
		super.styleDidChange()
		let style = self.style()
		titleLabel.textColor = style.color.label
		contentStackView.setCustomSpacing(style.dimension.directionalInsets1.top, after: detailLabel)
		directionalLayoutMargins = style.dimension.directionalInsets1
	}

	override open func tintColorDidChange() {
		super.tintColorDidChange()
		applyTintColor()
	}
}
