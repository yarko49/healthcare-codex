//
//  FollowViewController.swift
//  Allie
//
//  Created by Onseen on 2/18/22.
//

import CareKitStore
import Combine
import SwiftUI
import UIKit

protocol FollowViewControllerDelegate: AnyObject {
	func onClickDoneButton()
}

class FollowViewController: UIViewController {
	@ObservedObject var viewModel: NewDailyTasksPageViewModel = .init()
	private var subscriptions = Set<AnyCancellable>()
	private var selectedDate = Date()
	weak var delegate: FollowViewControllerDelegate?

	init(viewModel: NewDailyTasksPageViewModel, date: Date) {
		self.viewModel = viewModel
		self.selectedDate = date
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private let containerStackView: UIStackView = {
		let containerStackView = UIStackView()
		containerStackView.translatesAutoresizingMaskIntoConstraints = false
		containerStackView.alignment = .top
		containerStackView.axis = .vertical
		containerStackView.distribution = .fill
		return containerStackView
	}()

	private let tableContainerView: UIView = {
		let tableContainerView = UIView()
		tableContainerView.translatesAutoresizingMaskIntoConstraints = false
		tableContainerView.backgroundColor = .white
		return tableContainerView
	}()

	private let closeButton: UIButton = {
		let closeButton = UIButton()
		closeButton.translatesAutoresizingMaskIntoConstraints = false
		closeButton.backgroundColor = .black
		closeButton.setTitle("", for: .normal)
		closeButton.layer.cornerRadius = 22.0
		closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
		closeButton.tintColor = .allieWhite
		return closeButton
	}()

	private let title1: UILabel = {
		let title1 = UILabel()
		title1.translatesAutoresizingMaskIntoConstraints = false
		title1.attributedText = "Sorry you're not feeling great.".attributedString(style: .silkabold20, foregroundColor: UIColor.black, letterSpacing: -0.41)
		title1.numberOfLines = 0
		title1.lineBreakMode = .byWordWrapping
		return title1
	}()

	private let title2: UILabel = {
		let title2 = UILabel()
		title2.translatesAutoresizingMaskIntoConstraints = false
		title2.attributedText = "Do you have any of these symptoms?".attributedString(style: .silkabold24, foregroundColor: .mainBlue, letterSpacing: -0.41)
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
		doneButton.backgroundColor = .black
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
		buttonContainerView.setShadow()
		return buttonContainerView
	}()

	private let confirmedContainerView: UIView = {
		let confirmedContainerView = UIView()
		confirmedContainerView.translatesAutoresizingMaskIntoConstraints = false
		confirmedContainerView.backgroundColor = .mainBlue
		return confirmedContainerView
	}()

	private let symptomsLabel: UILabel = {
		let symptomsLabel = UILabel()
		symptomsLabel.translatesAutoresizingMaskIntoConstraints = false
		symptomsLabel.attributedText = "Thanks for adding\nyour symptoms.\n\nHope you feel\nbetter soon!".attributedString(style: .silkabold24, foregroundColor: .white)
		symptomsLabel.lineBreakMode = .byWordWrapping
		symptomsLabel.numberOfLines = 0
		symptomsLabel.textAlignment = .center
		return symptomsLabel
	}()

	private let symptomsImage: UIImageView = {
		let symptomsImage = UIImageView()
		symptomsImage.translatesAutoresizingMaskIntoConstraints = false
		symptomsImage.image = UIImage(named: "img-symptoms")
		symptomsImage.contentMode = .scaleAspectFill
		return symptomsImage
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		setupViews()
		viewModel.$symptomData
			.receive(on: DispatchQueue.main)
			.sink { [weak self] follows in
				self?.tableView.reloadData()
				let checkedFollow = follows.filter { follow in
					follow.isSelected
				}
				self?.doneButton.isEnabled = !checkedFollow.isEmpty
				self?.doneButton.backgroundColor = UIColor.black.withAlphaComponent(checkedFollow.isEmpty ? 0.5 : 1)
			}
			.store(in: &subscriptions)
	}

	private func setupViews() {
		view.backgroundColor = .mainBackground
		view.addSubview(containerStackView)
		[tableContainerView, confirmedContainerView].forEach { containerStackView.addArrangedSubview($0) }
		[closeButton, title1, title2, tableView, buttonContainerView].forEach { tableContainerView.addSubview($0) }
		[symptomsLabel, symptomsImage].forEach { confirmedContainerView.addSubview($0) }

		containerStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		containerStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		containerStackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true

		confirmedContainerView.isHidden = true

		tableContainerView.widthAnchor.constraint(equalTo: containerStackView.widthAnchor).isActive = true
		confirmedContainerView.widthAnchor.constraint(equalTo: containerStackView.widthAnchor).isActive = true

		closeButton.centerXAnchor.constraint(equalTo: tableContainerView.centerXAnchor).isActive = true
		closeButton.topAnchor.constraint(equalTo: tableContainerView.topAnchor, constant: 60).isActive = true
		closeButton.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
		closeButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
		closeButton.addTarget(self, action: #selector(onClickCloseButton), for: .touchUpInside)

		title1.centerXAnchor.constraint(equalTo: tableContainerView.centerXAnchor).isActive = true
		title1.leadingAnchor.constraint(equalTo: tableContainerView.leadingAnchor, constant: 24).isActive = true
		title1.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 45.0).isActive = true

		title2.centerXAnchor.constraint(equalTo: tableContainerView.centerXAnchor).isActive = true
		title2.leadingAnchor.constraint(equalTo: tableContainerView.leadingAnchor, constant: 24).isActive = true
		title2.topAnchor.constraint(equalTo: title1.bottomAnchor, constant: 10.0).isActive = true

		buttonContainerView.centerXAnchor.constraint(equalTo: tableContainerView.centerXAnchor).isActive = true
		buttonContainerView.leadingAnchor.constraint(equalTo: tableContainerView.leadingAnchor).isActive = true
		buttonContainerView.bottomAnchor.constraint(equalTo: tableContainerView.bottomAnchor).isActive = true

		buttonContainerView.addSubview(doneButton)
		doneButton.centerXAnchor.constraint(equalTo: buttonContainerView.centerXAnchor).isActive = true
		doneButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor, constant: 24).isActive = true
		doneButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor, constant: -44).isActive = true
		doneButton.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor, constant: 34.0).isActive = true
		doneButton.addTarget(self, action: #selector(onClickDoneButton), for: .touchUpInside)

		tableView.centerXAnchor.constraint(equalTo: tableContainerView.centerXAnchor).isActive = true
		tableView.leadingAnchor.constraint(equalTo: tableContainerView.leadingAnchor).isActive = true
		tableView.topAnchor.constraint(equalTo: title2.bottomAnchor, constant: 10.0).isActive = true
		tableView.bottomAnchor.constraint(equalTo: buttonContainerView.topAnchor, constant: 10).isActive = true
		tableView.rowHeight = 75
		tableView.register(FollowCell.self, forCellReuseIdentifier: FollowCell.cellID)
		tableView.delegate = self
		tableView.dataSource = self

		symptomsImage.centerXAnchor.constraint(equalTo: confirmedContainerView.centerXAnchor).isActive = true
		symptomsImage.bottomAnchor.constraint(equalTo: confirmedContainerView.bottomAnchor).isActive = true
		symptomsImage.leadingAnchor.constraint(equalTo: confirmedContainerView.leadingAnchor).isActive = true

		symptomsLabel.centerXAnchor.constraint(equalTo: confirmedContainerView.centerXAnchor).isActive = true
		symptomsLabel.bottomAnchor.constraint(equalTo: symptomsImage.topAnchor, constant: -40).isActive = true
	}

	@objc func onClickCloseButton() {
		dismiss(animated: true)
	}

	@objc func onClickDoneButton() {
		tableContainerView.isHidden = true
		confirmedContainerView.isHidden = false
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
			self?.dismiss(animated: true) {
				self?.delegate?.onClickDoneButton()
			}
		}
	}
}

extension FollowViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: FollowCell.cellID, for: indexPath) as? FollowCell {
			cell.configureCell(follow: viewModel.symptomData[indexPath.row])
			cell.selectionStyle = .none
			return cell
		}
		fatalError("can not deque cell")
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.symptomData.count
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
		let followModel = viewModel.symptomData[indexPath.row]
		guard let task = followModel.event.task as? OCKTask else { return }
		let viewController = GeneralizedLogTaskDetailViewController()
		viewController.queryDate = OCKEventQuery(for: selectedDate).dateInterval.start
		viewController.anyTask = task
		viewController.outcomeIndex = 0
		var outComes = [OCKOutcomeValue]()
		if let outcome = followModel.event.outcome, !outcome.values.isEmpty {
			outComes.append(outcome.values.first!)
		}
		viewController.outcomeValues = outComes
		viewController.modalPresentationStyle = .overFullScreen
		viewController.cancelAction = { [weak viewController] in
			viewController?.dismiss(animated: true, completion: nil)
		}
		viewController.outcomeValueHandler = { [weak viewController, weak self] newOutcomeValue in
			guard let strongSelf = self, let task = viewController?.anyTask as? OCKTask, let carePlanId = task.carePlanId else {
				return
			}
			if followModel.isSelected {
				guard let index = viewController?.outcomeIndex, let outcome = followModel.event.outcome as? OCKOutcome, index < outcome.values.count else {
					return
				}
				strongSelf.viewModel.updateOutcomeValue(newValue: newOutcomeValue, for: outcome, event: followModel.event, at: index, task: task) { result in
					switch result {
					case .success:
						ALog.info("Updated successfully")
						strongSelf.viewModel.updateFollows(at: indexPath.row)
					case .failure(let error):
						ALog.error("failed updating", error: error)
					}
					DispatchQueue.main.async {
						viewController?.dismiss(animated: true, completion: nil)
					}
				}
			} else {
				strongSelf.viewModel.addOutcomeValue(newValue: newOutcomeValue, carePlanId: carePlanId, task: task, event: followModel.event) { result in
					switch result {
					case .failure(let error):
						ALog.error("Error appending outcomes", error: error)
					case .success(let outcome):
						ALog.info("Did append value \(outcome.uuid)")
						strongSelf.viewModel.updateFollows(at: indexPath.row)
					}
					DispatchQueue.main.async {
						viewController?.dismiss(animated: true, completion: nil)
					}
				}
			}
		}
		showDetailViewController(viewController, sender: self)
	}
}
