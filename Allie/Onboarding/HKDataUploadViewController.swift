//
//  HKDataUploadViewController.swift
//  Allie
//

import Foundation
import UIKit

class HKDataUploadViewController: BaseViewController {
	var queryAction: AllieActionHandler?

	override func viewDidLoad() {
		super.viewDidLoad()
		waitLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(waitLabel)
		NSLayoutConstraint.activate([waitLabel.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 4.0),
		                             waitLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: waitLabel.trailingAnchor, multiplier: 2.0)])

		progressBar.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(progressBar)
		NSLayoutConstraint.activate([progressBar.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 5.0),
		                             progressBar.topAnchor.constraint(equalToSystemSpacingBelow: waitLabel.bottomAnchor, multiplier: 5.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: progressBar.trailingAnchor, multiplier: 5.0)])
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "HKDataUploadView"])
	}

	var titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.numberOfLines = 3
		label.textAlignment = .center
		let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 28.0, weight: .regular), .foregroundColor: UIColor.black, .kern: NSNumber(0.36)]
		label.attributedText = NSAttributedString(string: .importingHealthData, attributes: attributes)
		return label
	}()

	var waitLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.numberOfLines = 1
		label.textAlignment = .center
		let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17.0, weight: .regular), .foregroundColor: UIColor.grey, .kern: NSNumber(-0.32)]
		label.attributedText = NSAttributedString(string: .justASec, attributes: attributes)
		return label
	}()

	let progressBar: UIProgressView = {
		let view = UIProgressView(progressViewStyle: .bar)
		return view
	}()

	var maxProgress: Int = 0
	var progress: Int = 0 {
		didSet {
			guard maxProgress > 0 else {
				progressBar.setProgress(0, animated: true)
				return
			}
			let value = Float(progress / maxProgress)
			progressBar.setProgress(value, animated: true)
		}
	}

	// MARK: - Setup

	override func populateData() {
		super.populateData()
		queryAction?()
	}
}
