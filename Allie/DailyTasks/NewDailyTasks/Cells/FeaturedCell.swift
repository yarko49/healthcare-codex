//
//  FeaturedCell.swift
//  Allie
//
//  Created by Onseen on 2/9/22.
//

import UIKit
import SDWebImage
import CareKitStore
import CodexFoundation

class FeaturedCell: UICollectionViewCell {

    static let cellID: String = "FeaturedCell"
    var timelineViewModel: TimelineItemViewModel!
    @Injected(\.careManager) var careManager: CareManager

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
        imageView.layer.cornerRadius = 8.0
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private var title: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .systemFont(ofSize: 18, weight: .bold)
        title.numberOfLines = 0
        title.lineBreakMode = .byWordWrapping
        title.textColor = .white
        return title
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
        [imageView, title].forEach { container.addSubview($0) }
        container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        container.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5.0).isActive = true
        container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0).isActive = true

        imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        let topAnchor = imageView.topAnchor.constraint(equalTo: container.topAnchor)
        topAnchor.priority = .defaultLow
        topAnchor.isActive = true
        imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 250.0).isActive = true

        title.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20).isActive = true
        title.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20).isActive = true
        title.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
    }

    func configureCell(timelineItemViewModel: TimelineItemViewModel) {
        self.timelineViewModel = timelineItemViewModel
        title.text = timelineItemViewModel.timelineItemModel.event.task.title ?? ""
        if let task = timelineViewModel.timelineItemModel.event.task as? OCKTask? {
            if let task = task, let asset = task.asset, !asset.isEmpty {
                careManager.image(task: task) { [weak self] result in
                    switch result {
                    case .failure(let error):
                        ALog.error("unable to download image", error: error)
                    case .success(let image):
                        DispatchQueue.main.async {
                            self?.imageView.image = image
                        }
                    }
                }
            } else {
                let faturedURL = task?.featuredContentImageURL
                imageView.sd_setImage(with: faturedURL, completed: nil)
            }
        }
    }
}
