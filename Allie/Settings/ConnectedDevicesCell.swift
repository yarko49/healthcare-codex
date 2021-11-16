//
//  ConnectedDevicesCell.swift
//  Allie
//
//  Created by Waqar Malik on 11/4/21.
//

import UIKit

class ConnectedDevicesCell: UITableViewCell {
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
		commontInit()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}

	private func commontInit() {
		bottomSeperator.translatesAutoresizingMaskIntoConstraints = false
		addSubview(bottomSeperator)
		NSLayoutConstraint.activate([bottomSeperator.leadingAnchor.constraint(equalTo: leadingAnchor),
		                             trailingAnchor.constraint(equalTo: bottomSeperator.trailingAnchor),
		                             bottomAnchor.constraint(equalTo: bottomSeperator.bottomAnchor),
		                             bottomSeperator.heightAnchor.constraint(equalToConstant: 0.5)])
	}

	private let bottomSeperator: UIView = {
		let view = UIView(frame: .zero)
		view.backgroundColor = .allieSeparator
		return view
	}()
}
