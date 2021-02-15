//
//  MeasurementCardCell.swift
//  Allie
//

import Foundation
import UIKit

class MeasurementCardCell: UICollectionViewCell {
	// MARK: - IBOutlets

	@IBOutlet var mainView: UIView!
	@IBOutlet var iconView: CircleProgressBarView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var timeLabel: UILabel!
	@IBOutlet var textLabel: UILabel!
	@IBOutlet var statusImageView: UIImageView!
	@IBOutlet var statusLabel: UILabel!
	@IBOutlet var addImageView: UIImageView!
	@IBOutlet var surveyLabel: UILabel!
	@IBOutlet var surveyImageView: UIImageView!

	// MARK: - Vars

	var card: NotificationCardData?

	var backgroundClr = UIColor.defaultDataBackground {
		didSet {
			mainView.backgroundColor = backgroundClr
		}
	}

	var statusClr = UIColor.statusGreen {
		didSet {
			statusImageView.tintColor = statusClr
		}
	}

	var title: String? {
		didSet {
			if let title = title {
				titleLabel.isHidden = false
				titleLabel.attributedText = title.with(style: .regular13, andColor: .black, andLetterSpacing: -0.408)
			} else {
				titleLabel.isHidden = true
			}
		}
	}

	var timestamp: String? {
		didSet {
			timeLabel.isHidden = true
			// TODO: This should change, it's a temporary fix because there are multiple formats from BE rn
			if let timestamp = timestamp {
				var date = DateFormatter.wholeDateNoTimeZoneRequest.date(from: timestamp)
				if date == nil {
					date = DateFormatter.wholeDateRequest.date(from: timestamp)
				}
				if let date = date {
					var dateString = ""
					if Calendar.current.isDateInToday(date) {
						let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: date, to: Date())
						let hours = diffComponents.hour
						dateString = hours == 0 ? Str.now : DateFormatter.hmma.string(from: date)
					} else if Calendar.current.isDateInYesterday(date) {
						dateString = Str.yesterday
					} else {
						dateString = DateFormatter.MMMdd.string(from: date)
					}

					timeLabel.attributedText = dateString.with(style: .regular13, andColor: .lightGrey, andLetterSpacing: -0.16)
				}
			}
		}
	}

	var status: String? {
		didSet {
			if let status = status {
				statusLabel.isHidden = false
				statusLabel.attributedText = status.with(style: .regular13, andColor: .lightGrey, andLetterSpacing: -0.16)
			} else {
				statusLabel.isHidden = true
			}
		}
	}

	var text: String? {
		didSet {
			if let text = text {
				textLabel.isHidden = false
				textLabel.attributedText = setAttributedString(for: text)
				setAppearanceForDataInput(flag: false)
			} else {
				setAppearanceForDataInput(flag: true)
				setCellForDataInput()
			}
		}
	}

	// MARK: - Setup

	func setupView() {
		contentView.layer.cornerRadius = 5.0
		contentView.layer.borderWidth = 1.0
		contentView.layer.borderColor = UIColor.clear.cgColor
		contentView.layer.masksToBounds = true

		layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
		layer.shadowOffset = CGSize(width: 0, height: 3.0)
		layer.shadowRadius = 8.0
		layer.shadowOpacity = 1.0
		layer.masksToBounds = false
		layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
		layer.backgroundColor = UIColor.clear.cgColor
	}

	func setupCell(with card: NotificationCardData) {
		setupView()

		self.card = card

		if let color = UIColor(hex: card.backgroundColor) {
			backgroundClr = color
		}

		statusImageView.image = statusImageView.image?.withRenderingMode(.alwaysTemplate)

		if let statusColorHex = card.statusColor, let color = UIColor(hex: statusColorHex) {
			statusClr = color
		}

		if let color = card.progressColor, let opacity = card.progressOpacity, let progress = card.progressPercent, let icon = card.icon {
			iconView.setup(color: color, opacity: opacity, icon: icon)
			iconView.setProgressWithAnimation(value: progress)
		} else {
			iconView.setup(color: "#000000", opacity: 1.0, icon: IconType(rawValue: "default"))
			iconView.setProgressWithAnimation(value: 0)
		}

		surveyLabel.attributedText = Str.completeSurvey.with(style: .regular13, andColor: .lightGrey, andLetterSpacing: -0.16)
		let surveyImage = surveyImageView.image?.withRenderingMode(.alwaysTemplate)
		surveyImageView.image = surveyImage
		surveyImageView.tintColor = .lightGrey

		title = card.title
		timestamp = card.sampledTime
		status = card.status
		text = card.text
		setAppeareanceOnAction(action: card.action)
	}

	private func setAttributedString(for text: String) -> NSMutableAttributedString {
		let array = text.components(separatedBy: " ")
		let attributedString = text.with(style: .regular26, andColor: .black, andLetterSpacing: -0.16) as? NSMutableAttributedString
		if array.count > 1 {
			let range = (text as NSString).range(of: array[1])
			attributedString?.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 26.0, weight: .thin), range: range)
		}
		return attributedString!
	}

	private func setCellForDataInput() {
		switch card?.action {
		case .bloodPressure:
			textLabel.attributedText = Str.enterBP.with(style: .regular24, andColor: .enterGrey, andLetterSpacing: -0.16)
			return
		case .weight:
			textLabel.attributedText = Str.enterWeight.with(style: .regular24, andColor: .enterGrey, andLetterSpacing: -0.16)
			return
		default:
			break
		}
		textLabel.isHidden = true
		addImageView.isHidden = true
	}

	private func setAppeareanceOnAction(action: CardAction?) {
		let questionnaireFlag = action == .questionnaire

		surveyImageView.isHidden = !questionnaireFlag
		surveyLabel.isHidden = !questionnaireFlag
		if questionnaireFlag {
			if card?.progressPercent == 1 {
				statusLabel.isHidden = false
				statusImageView.isHidden = false
				timeLabel.isHidden = false
				addImageView.isHidden = true
				surveyImageView.isHidden = true
				surveyLabel.isHidden = true
			} else {
				statusLabel.isHidden = questionnaireFlag
				statusImageView.isHidden = questionnaireFlag
				timeLabel.isHidden = questionnaireFlag
				addImageView.isHidden = questionnaireFlag
			}
		}
	}

	private func setAppearanceForDataInput(flag: Bool) {
		addImageView.isHidden = !flag
		statusImageView.isHidden = flag
		statusLabel.isHidden = flag
		timeLabel.isHidden = flag
	}
}
