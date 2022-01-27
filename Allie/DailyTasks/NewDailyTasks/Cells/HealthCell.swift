//
//  HealthCell.swift
//  Allie
//
//  Created by Onseen on 1/26/22.
//

import UIKit

enum HealthType {
    case glucose
    case insulin
    case aspirin
    case add
}

class HealthCell: UICollectionViewCell {

    static let cellID: String = "HealthCell"

    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
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

    private var container: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 8.0
        return container
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        self.backgroundColor = .clear
        contentView.addSubview(stepStack)
        contentView.addSubview(contentStack)
        stepStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        stepStack.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stepStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        contentStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        contentStack.leadingAnchor.constraint(equalTo: stepStack.trailingAnchor, constant: 20).isActive = true
        stepStack.addArrangedSubview(topDash)
        topDash.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
        topDash.heightAnchor.constraint(equalToConstant: 20).isActive = true
        stepStack.addArrangedSubview(imageView)
        imageView.widthAnchor.constraint(equalToConstant: 28.0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 28.0).isActive = true
        stepStack.addArrangedSubview(bottomDash)
        bottomDash.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
        bottomDash.heightAnchor.constraint(equalToConstant: 20).isActive = true

        contentStack.addArrangedSubview(title)
        contentStack.addArrangedSubview(subTitle)
    }

    func configureCell(cellType: HealthType, index: Int, isEmpty: Bool) {
        switch cellType {
        case .glucose:
            imageView.image = UIImage(systemName: "heart.circle")
            imageView.tintColor = .mainRed
            title.text = "Blood Glucose"
            if isEmpty {
                subTitle.text = "Log reading"
            } else {
                subTitle.text = "08:50, 205.6 mg/dL, Fasting"
            }
        case .insulin:
            imageView.image = UIImage(systemName: "heart.circle")
            imageView.tintColor = .mainLightRed
            title.text = "Insulin"
            if isEmpty {
                subTitle.text = "Log reading"
            } else {
                subTitle.text = "08:50, 12u"
            }
        case .aspirin:
            imageView.image = UIImage(systemName: "heart.circle")
            imageView.tintColor = .mainLightBlue
            title.text = "Aspirin 5mg"
            subTitle.text = "Due this afternoon"
        case .add:
            imageView.image = UIImage(systemName: "heart.circle")
            imageView.tintColor = .mainGray
            title.isHidden = true
            subTitle.text = "Log something else"
        }
    }
}

extension UIView {
    func createDottedLine(width: CGFloat, color: CGColor) {
        let caShapeLayer = CAShapeLayer()
        caShapeLayer.strokeColor = UIColor.red.cgColor
        caShapeLayer.lineWidth = width
        caShapeLayer.lineDashPattern = [2, 2]
        let cgPath = CGMutablePath()
        let cgPoint = [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: self.frame.height)]
        cgPath.addLines(between: cgPoint)
        caShapeLayer.path = cgPath
        layer.addSublayer(caShapeLayer)
    }
}
