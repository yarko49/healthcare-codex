//
//  CarePlanFeatureCell.swift
//  Allie
//
//  Created by Onseen on 2/21/22.
//

import CareKitStore
import CareModel
import CodexFoundation
import UIKit

class CarePlanFeatureCell: UICollectionViewCell {
	@Injected(\.careManager) var careManager: CareManager
	static let cellID: String = "CarePlanFeatureCell"

	private var container: UIView = {
		let container = UIView()
		container.translatesAutoresizingMaskIntoConstraints = false
		container.backgroundColor = .white
		container.layer.cornerRadius = 8.0
		container.layer.masksToBounds = true
		container.setShadow()
		return container
	}()

	private var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.layer.cornerRadius = 8.0
		imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		imageView.clipsToBounds = true
		return imageView
	}()

	private var bottomStackView: UIStackView = {
		let bottomStackView = UIStackView()
		bottomStackView.translatesAutoresizingMaskIntoConstraints = false
		bottomStackView.axis = .horizontal
		bottomStackView.alignment = .center
		bottomStackView.spacing = 10.0
		bottomStackView.distribution = .fill
		return bottomStackView
	}()

	private var icon: UIImageView = {
		let icon = UIImageView()
		icon.translatesAutoresizingMaskIntoConstraints = false
		icon.layer.cornerRadius = 13.0
		icon.layer.masksToBounds = true
		return icon
	}()

	private var title: UILabel = {
		let title = UILabel()
		title.translatesAutoresizingMaskIntoConstraints = false
		title.numberOfLines = 0
		title.lineBreakMode = .byWordWrapping
		title.textAlignment = .left
		return title
	}()

	private var fileType: UIButton = {
		let fileType = UIButton()
		fileType.translatesAutoresizingMaskIntoConstraints = false
		fileType.contentHorizontalAlignment = .right
		return fileType
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupViews() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		contentView.addSubview(container)
		[imageView, bottomStackView].forEach { container.addSubview($0) }
		[icon, title, fileType].forEach { bottomStackView.addArrangedSubview($0) }

		container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
		container.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5.0).isActive = true
		container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0).isActive = true

		imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
		let topAnchor = imageView.topAnchor.constraint(equalTo: container.topAnchor)
		topAnchor.priority = .defaultLow
		topAnchor.isActive = true
		imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
		imageView.heightAnchor.constraint(equalToConstant: 250.0).isActive = true

		bottomStackView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
		bottomStackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.0).isActive = true
		bottomStackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20.0).isActive = true
		bottomStackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20.0).isActive = true
		icon.heightAnchor.constraint(equalToConstant: 26.0).isActive = true
		icon.widthAnchor.constraint(equalToConstant: 26.0).isActive = true
	}

	func configureCell(for task: CHTasks) {
		let ockTask = OCKTask(task: task.first!)
		careManager.image(task: ockTask) { [weak self] result in
			switch result {
			case .failure(let error):
				ALog.error("unable to download image", error: error)
			case .success(let image):
				DispatchQueue.main.async {
					self?.imageView.image = image
				}
			}
		}
		if let identifier = task.first?.groupIdentifierType, let iconImage = identifier.icon {
			icon.image = iconImage
		} else {
			icon.image = UIImage(named: "icon-empty")
		}
		title.attributedText = task.first?.title?.attributedString(style: .bold20, foregroundColor: UIColor.black, letterSpacing: -0.41)
		if let fileExtension = task.first?.userInfo?["detailViewAsset"]?.components(separatedBy: ".").last {
			fileType.setAttributedTitle(fileExtension.uppercased().attributedString(style: .regular13, foregroundColor: .allieGray, letterSpacing: -0.025), for: .normal)
		} else {
			fileType.setTitle("", for: .normal)
		}
	}
}
