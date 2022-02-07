//
//  HealthAddCell.swift
//  Allie
//
//  Created by Onseen on 1/27/22.
//

import UIKit

class HealthAddCell: UICollectionViewCell {

    static let cellID: String = "HealthAddCell"

    let borderLayer = CAShapeLayer()

    private var container: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()

    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 14.0
        imageView.backgroundColor = .mainGray
        return imageView
    }()

    private var title: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .systemFont(ofSize: 18, weight: .bold)
        title.textColor = .black
        return title
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

    private var addButton: UIButton = {
        let addButton = UIButton()
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.backgroundColor = .clear
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.imageView?.tintColor = .mainGray
        addButton.layer.cornerRadius = 22
        addButton.layer.borderColor = UIColor.mainGray?.cgColor
        addButton.layer.borderWidth = 1.0
        return addButton
    }()

    private var subTitle: UILabel = {
        let subTitle = UILabel()
        subTitle.translatesAutoresizingMaskIntoConstraints = false
        subTitle.font = .systemFont(ofSize: 14)
        subTitle.textColor = .mainGray
        subTitle.text = "Log something else"
        return subTitle
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        container.addLineDashedBorder(pattern: [4, 4], radius: 8, color: UIColor.mainGray!.cgColor)
    }

    func setupViews() {
        self.backgroundColor = .clear
        contentView.addSubview(container)
        container.addSubview(contentStack)
        container.addSubview(imageView)
        container.addSubview(addButton)
        contentStack.addArrangedSubview(subTitle)

        container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        container.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5.0).isActive = true
        container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true

        imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 28.0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 28.0).isActive = true
        imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.0).isActive = true
        imageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 30.0).isActive = true

        contentStack.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        contentStack.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 20.0).isActive = true

        addButton.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        addButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20.0).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
    }
}
