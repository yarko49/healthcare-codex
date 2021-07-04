//
//  ConnectProviderView.swift
//  Allie
//
//  Created by Waqar Malik on 6/24/21.
//

import UIKit

class ConnectProviderView: UIStackView {
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	@available(*, unavailable)
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	let titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
		label.textColor = .allieGray
		label.numberOfLines = 0
		label.text = NSLocalizedString("CONNECT_PROVIDER.title", comment: "Connect to your healthcare provider to get the full benefits of Allie")
		return label
	}()

	let imageView: UIImageView = {
		let image = UIImage(named: "illustration10")
		let view = UIImageView(image: image)
		view.contentMode = .scaleAspectFit
		return view
	}()

	let connectButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle(NSLocalizedString("CONNECT", comment: "Connect"), for: .normal)
		button.setTitleColor(.allieWhite, for: .normal)
		button.backgroundColor = .allieGray
		button.layer.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
		button.clipsToBounds = true
		button.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
		return button
	}()

	private func commonInit() {
		let views = [titleLabel, imageView, connectButton]
		views.forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addArrangedSubview($0)
		}
	}
}
