//
//  HealthEmptyCell.swift
//  Allie
//
//  Created by Onseen on 1/26/22.
//

import UIKit

class HealthEmptyCell: UICollectionViewCell {

    static let cellID: String = "HealthEmptyCell"

    private var container: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 8.0
        return container
    }()

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
        addButton.backgroundColor = .black
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.imageView?.tintColor = .white
        addButton.layer.cornerRadius = 22
        return addButton
    }()

    private var subTitle: UILabel = {
        let subTitle = UILabel()
        subTitle.translatesAutoresizingMaskIntoConstraints = false
        subTitle.font = .systemFont(ofSize: 14)
        subTitle.textColor = .mainGray
        return subTitle
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.backgroundColor = .clear
        contentView.addSubview(container)
        container.addSubview(contentStack)
        container.addSubview(imageView)
        container.addSubview(addButton)
        contentStack.addArrangedSubview(title)
        contentStack.addArrangedSubview(subTitle)

        container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        container.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5.0).isActive = true
        container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0).isActive = true

        imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 28.0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 28.0).isActive = true
        imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.0).isActive = true
        imageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 30.0).isActive = true

        contentStack.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        contentStack.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 20.0).isActive = true

        addButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        addButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20.0).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
    }

    func configureCell(cellType: HealthType) {
        switch cellType {
        case .glucose:
            imageView.image = #imageLiteral(resourceName: "icon-blood-glucose.pdf")
            title.text = "Blood Glucose"
            subTitle.text = "Log reading"
        case .insulin:
            imageView.image = #imageLiteral(resourceName: "icon-insulin.pdf")
            title.text = "Insulin"
            subTitle.text = "Log dosage"
        case .asprin:
            imageView.image = #imageLiteral(resourceName: "icon-symptoms.pdf")
            title.text = "Asprint 5mg"
            subTitle.text = "Due this afternoon"
        }
    }
}

extension UIView {
    @discardableResult
    func addLineDashedBorder(
        pattern: [NSNumber]?, radius: CGFloat, color: CGColor
    ) -> CALayer {
        layer.masksToBounds = true
        layer.cornerRadius = radius
        let borderLayer = CAShapeLayer()
        borderLayer.strokeColor = color
        borderLayer.lineDashPattern = pattern
        borderLayer.frame = bounds
        borderLayer.fillColor = nil
        borderLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        layer.addSublayer(borderLayer)
        return borderLayer
    }
}
