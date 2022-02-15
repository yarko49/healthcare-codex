//
//  HealthCell.swift
//  Allie
//
//  Created by Onseen on 1/26/22.
//

import CareKit
import CareKitStore
import UIKit

enum HealthType {
	case glucose
	case insulin
	case asprin
}

protocol HealthFilledCellDelegate: AnyObject {
	func onClickCell(timelineItemViewModel: TimelineItemViewModel)
}

class HealthFilledCell: UICollectionViewCell {
	static let cellID: String = "HealthFilledCell"

	weak var delegate: HealthFilledCellDelegate?
	var timelineViewModel: TimelineItemViewModel!

	private var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.layer.cornerRadius = 14.0
		imageView.clipsToBounds = true
		return imageView
	}()

	private var title: UILabel = {
		let title = UILabel()
		title.translatesAutoresizingMaskIntoConstraints = false
		title.font = .systemFont(ofSize: 18, weight: .bold)
		title.textColor = .black
		return title
	}()

	private var subTitle: UILabel = {
		let subTitle = UILabel()
		subTitle.translatesAutoresizingMaskIntoConstraints = false
		subTitle.font = .systemFont(ofSize: 14)
		subTitle.textColor = .mainGray
		return subTitle
	}()

	var topDash: UIView = {
		let topDash = UIView()
		topDash.translatesAutoresizingMaskIntoConstraints = false
		topDash.backgroundColor = .mainLightGray
		return topDash
	}()

	var bottomDash: UIView = {
		let bottomDash = UIView()
		bottomDash.translatesAutoresizingMaskIntoConstraints = false
		bottomDash.backgroundColor = .mainLightGray
		return bottomDash
	}()

	private var stepStack: UIStackView = {
		let stepStack = UIStackView()
		stepStack.translatesAutoresizingMaskIntoConstraints = false
		stepStack.axis = .vertical
		stepStack.alignment = .center
		stepStack.distribution = .fill
		stepStack.spacing = 0
		return stepStack
	}()

	private var contentStack: UIStackView = {
		let contentStack = UIStackView()
		contentStack.translatesAutoresizingMaskIntoConstraints = false
		contentStack.axis = .vertical
		contentStack.alignment = .leading
		contentStack.distribution = .fill
		contentStack.spacing = 4.0
		return contentStack
	}()

	private let actionButton: UIButton = {
		let actionButton = UIButton()
		actionButton.translatesAutoresizingMaskIntoConstraints = false
		actionButton.backgroundColor = .clear
		actionButton.setTitle("", for: .normal)
		return actionButton
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setupViews() {
		backgroundColor = .clear
		contentView.addSubview(stepStack)
		contentView.addSubview(contentStack)
		contentView.addSubview(actionButton)
		stepStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		stepStack.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
		stepStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true
		contentStack.centerYAnchor.constraint(equalTo: stepStack.centerYAnchor).isActive = true
		contentStack.leadingAnchor.constraint(equalTo: stepStack.trailingAnchor, constant: 20).isActive = true
		stepStack.addArrangedSubview(topDash)
		topDash.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
		topDash.heightAnchor.constraint(equalToConstant: 30).isActive = true
		stepStack.addArrangedSubview(imageView)
		imageView.widthAnchor.constraint(equalToConstant: 28.0).isActive = true
		imageView.heightAnchor.constraint(equalToConstant: 28.0).isActive = true
		stepStack.addArrangedSubview(bottomDash)
		bottomDash.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
		bottomDash.heightAnchor.constraint(equalToConstant: 30).isActive = true

		contentStack.addArrangedSubview(title)
		contentStack.addArrangedSubview(subTitle)

		actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		actionButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
		actionButton.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
		actionButton.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
		actionButton.addTarget(self, action: #selector(onActionButtonClick), for: .touchUpInside)
	}

	func configureCell(timelineViewModel: TimelineItemViewModel) {
		self.timelineViewModel = timelineViewModel
		let outComes = timelineViewModel.timelineItemModel.outcomeValues!
		let ockEvent = timelineViewModel.timelineItemModel.event
		title.text = ockEvent.task.title
		let quantityIdentifier = (ockEvent.task as? OCKHealthKitTask)?.healthKitLinkage.quantityIdentifier
		if let dataType = quantityIdentifier?.dataType {
			imageView.image = dataType.image
		} else if let identifier = ockEvent.task.groupIdentifierType, let icon = identifier.icon {
			imageView.image = icon
		} else {
			imageView.image = UIImage(named: "icon-empty")
		}
		let linkPage = (ockEvent.task as? OCKHealthKitTask)?.healthKitLinkage
		let date = outComes.first!.createdDate
		let dateString = ScheduleUtility.timeFormatter.string(from: date)
		var formattedValue = outComes.first?.formattedValue
		var context: String?
		if linkPage?.quantityIdentifier == .bloodPressureDiastolic {
			let systolicValue: OCKOutcomeValue = outComes[0]
			let diastolicValue: OCKOutcomeValue = outComes[1]
			context = systolicValue.symptomTitle
			formattedValue = String(format: "%d/%d", systolicValue.integerValue ?? 0, diastolicValue.integerValue ?? 0)
		}
		if linkPage?.quantityIdentifier == .insulinDelivery {
			context = outComes.first?.insulinReasonTitle
		} else if linkPage?.quantityIdentifier == .bloodGlucose {
			context = outComes.first?.bloodGlucoseMealTimeTitle
		} else {
			context = outComes.first?.symptomTitle
		}
		if let contextValue = context, !contextValue.replacingOccurrences(of: " ", with: "").isEmpty {
			if let formattedVal = formattedValue, !formattedVal.isEmpty {
				subTitle.text = "\(dateString), \(formattedVal), \(contextValue)"
			} else {
				subTitle.text = "\(dateString), \(contextValue)"
			}
		} else {
			if let formattedVal = formattedValue, !formattedVal.isEmpty {
				subTitle.text = "\(dateString), \(formattedVal)"
			} else {
				subTitle.text = "\(dateString)"
			}
		}
	}

	@objc func onActionButtonClick() {
		delegate?.onClickCell(timelineItemViewModel: timelineViewModel)
	}
}

extension UIView {
	func createDottedLine(width: CGFloat, color: CGColor) {
		let caShapeLayer = CAShapeLayer()
		caShapeLayer.strokeColor = UIColor.red.cgColor
		caShapeLayer.lineWidth = width
		caShapeLayer.lineDashPattern = [2, 2]
		let cgPath = CGMutablePath()
		let cgPoint = [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: frame.height)]
		cgPath.addLines(between: cgPoint)
		caShapeLayer.path = cgPath
		layer.addSublayer(caShapeLayer)
	}
}
