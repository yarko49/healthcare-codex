//
//  CarePlanLastCell.swift
//  Allie
//
//  Created by SwiftDev on 3/11/22.
//

import UIKit

class CarePlanLastCell: UICollectionViewCell {
	static let cellID: String = "CarePlanLastCell"

	private var imgBG: UIImageView = {
		let imgBG = UIImageView()
		imgBG.translatesAutoresizingMaskIntoConstraints = false
		imgBG.contentMode = .scaleAspectFill
		imgBG.clipsToBounds = true
		imgBG.image = #imageLiteral(resourceName: "img_lastBG")
		return imgBG
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
		contentView.addSubview(imgBG)
		imgBG.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
		imgBG.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		imgBG.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
		imgBG.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
	}
}
