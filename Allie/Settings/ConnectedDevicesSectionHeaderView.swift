//
//  ConnectedDevicesSectionHeaderView.swift
//  Allie
//
//  Created by Waqar Malik on 11/4/21.
//

import UIKit

class ConnectedDevicesSectionHeaderView: UITableViewHeaderFooterView {
	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		let view = UIView(frame: .zero)
		view.backgroundColor = .allieWhite
		backgroundView = view
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
