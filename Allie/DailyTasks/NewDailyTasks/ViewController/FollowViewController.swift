//
//  FollowViewController.swift
//  Allie
//
//  Created by Onseen on 2/18/22.
//

import Combine
import SwiftUI
import UIKit

class FollowViewController: UIViewController {
	@ObservedObject var viewModel: FollowViewModel = .init()
	private var subscriptions = Set<AnyCancellable>()

	private let closeButton: UIButton = {
		let closeButton = UIButton()
		closeButton.translatesAutoresizingMaskIntoConstraints = false
		closeButton.backgroundColor = .allieBlack
		closeButton.setTitle("", for: .normal)
		closeButton.layer.cornerRadius = 22.0
		closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
		closeButton.tintColor = .allieWhite
		return closeButton
	}()

	private let title1: UILabel = {
		let title1 = UILabel()
		title1.translatesAutoresizingMaskIntoConstraints = false
		title1.attributedText = "Sorry you're not feeling great.".attributedString(style: .bold20, foregroundColor: .allieBlack, letterSpacing: -0.41)
		title1.numberOfLines = 0
		title1.lineBreakMode = .byWordWrapping
		return title1
	}()

	private let title2: UILabel = {
		let title2 = UILabel()
		title2.translatesAutoresizingMaskIntoConstraints = false
		title2.attributedText = "Do you have any of these symptoms?".attributedString(style: .bold24, foregroundColor: .mainBlue, letterSpacing: -0.41)
		title2.numberOfLines = 0
		title2.lineBreakMode = .byWordWrapping
		return title2
	}()

	private var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .plain)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.backgroundColor = .clear
		tableView.layoutMargins = .zero
		tableView.separatorStyle = .none
		tableView.isScrollEnabled = true
		return tableView
	}()

	private var doneButton: BottomButton = {
		let doneButton = BottomButton(frame: .zero)
		doneButton.translatesAutoresizingMaskIntoConstraints = false
		doneButton.backgroundColor = .allieBlack
		doneButton.setTitle("Done", for: .normal)
		doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
		doneButton.setTitleColor(.white, for: .normal)
		doneButton.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
		return doneButton
	}()

	private let buttonContainerView: UIView = {
		let buttonContainerView = UIView()
		buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
		buttonContainerView.backgroundColor = .white
		return buttonContainerView
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		setupViews()
		viewModel.$followModels
			.receive(on: DispatchQueue.main)
			.sink { [weak self] follows in
				self?.tableView.reloadData()
				let checkedFollow = follows.filter { follow in
					follow.isSelected
				}
				self?.doneButton.isEnabled = !checkedFollow.isEmpty
				self?.doneButton.backgroundColor = UIColor.allieBlack.withAlphaComponent(checkedFollow.isEmpty ? 0.5 : 1)
			}
			.store(in: &subscriptions)
	}

	private func setupViews() {
		view.backgroundColor = .mainBackground
		[closeButton, title1, title2, tableView, buttonContainerView].forEach { view.addSubview($0) }
		closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
		closeButton.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
		closeButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
		closeButton.addTarget(self, action: #selector(onClickCloseButton), for: .touchUpInside)

		title1.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		title1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
		title1.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 45.0).isActive = true

		title2.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		title2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
		title2.topAnchor.constraint(equalTo: title1.bottomAnchor, constant: 10.0).isActive = true

		buttonContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		buttonContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		buttonContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

		buttonContainerView.addSubview(doneButton)
		doneButton.centerXAnchor.constraint(equalTo: buttonContainerView.centerXAnchor).isActive = true
		doneButton.centerYAnchor.constraint(equalTo: buttonContainerView.centerYAnchor).isActive = true
		doneButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor, constant: 24).isActive = true
		doneButton.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor, constant: 24.0).isActive = true
		doneButton.addTarget(self, action: #selector(onClickCloseButton), for: .touchUpInside)

		tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		tableView.topAnchor.constraint(equalTo: title2.bottomAnchor, constant: 10.0).isActive = true
		tableView.bottomAnchor.constraint(equalTo: buttonContainerView.topAnchor, constant: 10).isActive = true
		tableView.rowHeight = 75
		tableView.register(FollowCell.self, forCellReuseIdentifier: FollowCell.cellID)
		tableView.delegate = self
		tableView.dataSource = self
	}

	@objc func onClickCloseButton() {
		dismiss(animated: true)
	}
}

extension FollowViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: FollowCell.cellID, for: indexPath) as? FollowCell {
			cell.configureCell(follow: viewModel.followModels[indexPath.row])
			return cell
		}
		fatalError("can not deque cell")
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.followModels.count
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
		viewModel.updateFollows(at: indexPath.row)
	}
}
