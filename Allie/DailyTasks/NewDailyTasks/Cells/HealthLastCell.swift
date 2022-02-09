//
//  HealthLastCell.swift
//  Allie
//
//  Created by Onseen on 1/27/22.
//

import UIKit

class HealthLastCell: UICollectionViewCell {

    static let cellID: String = "HealthLastCell"

    private var imgBG: UIImageView = {
        let imgBG = UIImageView()
        imgBG.translatesAutoresizingMaskIntoConstraints = false
        imgBG.contentMode = .scaleAspectFill
        imgBG.clipsToBounds = true
        imgBG.image = #imageLiteral(resourceName: "img_lastBG")
        return imgBG
    }()

    private var imgFlower: UIImageView = {
        let imgFlower = UIImageView()
        imgFlower.translatesAutoresizingMaskIntoConstraints = false
        imgFlower.contentMode = .scaleAspectFill
        imgFlower.image = #imageLiteral(resourceName: "img_last")
        imgFlower.clipsToBounds = true
        return imgFlower
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(imgBG)
        contentView.addSubview(imgFlower)
        imgBG.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imgBG.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        imgBG.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imgBG.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imgFlower.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imgFlower.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        imgFlower.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imgFlower.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    }
}
