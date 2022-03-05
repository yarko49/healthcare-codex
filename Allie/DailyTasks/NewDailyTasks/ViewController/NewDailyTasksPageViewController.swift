//
//  NewDailyTasksPageViewController.swift
//  Allie
//
//  Created by Onseen on 1/25/22.
//
import BluetoothService
import CareKit
import CareKitStore
import CareKitUI
import CareModel
import CodexFoundation
import Combine
import CoreBluetooth
import Foundation
import HealthKit
import JGProgressHUD
import OmronKit
import SwiftUI
import UIKit

class NewDailyTasksPageViewController: BaseViewController {
	@Injected(\.careManager) var careManager: CareManager
	@Injected(\.healthKitManager) var healthKitManager: HealthKitManager
	@Injected(\.networkAPI) var networkAPI: AllieAPI
	@Injected(\.remoteConfig) var remoteConfig: RemoteConfigManager
	var bluetoothDevices: [UUID: Peripheral] = [:]
	var deviceInfoCache: [UUID: [OHQDeviceInfoKey: Any]] = [:]
	var stopScanCompletion: VoidCompletionHandler?
	var managerStateObserver: NSKeyValueObservation?
	var userData: [OHQUserDataKey: Any] = [:]
	var sessionData: SessionData?

	var addCellIndex: Int?

	@ObservedObject var viewModel: NewDailyTasksPageViewModel = .init()

	var timeInterval: TimeInterval = 60 * 10
	var cancellable: Set<AnyCancellable> = []
	private var shouldUpdateCarePlan: Bool = true
	private var insertViewsAnimated: Bool = true
	private var isRefreshingCarePlan = false
	var ockTasks: [OCKAnyTask] = .init()
	var selectedDate: Date = .init()

	private var subscriptions = Set<AnyCancellable>()

	private lazy var datePicker: UIDatePicker = {
		let datePicker = UIDatePicker()
		datePicker.translatesAutoresizingMaskIntoConstraints = false
		datePicker.preferredDatePickerStyle = .inline
		datePicker.datePickerMode = .date
		datePicker.setValue(UIColor.white, forKey: "backgroundColor")
		return datePicker
	}()

	private lazy var dateDecorationView: UIView = {
		let decorationView = UIView()
		decorationView.translatesAutoresizingMaskIntoConstraints = false
		decorationView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
		return decorationView
	}()

	private lazy var dateStackView: UIStackView = {
		let dateStackView = UIStackView()
		dateStackView.translatesAutoresizingMaskIntoConstraints = false
		dateStackView.axis = .vertical
		dateStackView.alignment = .fill
		dateStackView.distribution = .fill
		return dateStackView
	}()

	private var topView: DailyTaskTopView = {
		let topView = DailyTaskTopView()
		topView.translatesAutoresizingMaskIntoConstraints = false
		topView.setShadow()
		return topView
	}()

	private var collectionView: UICollectionView = {
		let size = NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
		                                  heightDimension: NSCollectionLayoutDimension.estimated(44))
		let item = NSCollectionLayoutItem(layoutSize: size)
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
		let section = NSCollectionLayoutSection(group: group)
		section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)
		section.interGroupSpacing = 0
		let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
		                                              heightDimension: .absolute(0))
		let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize,
		                                                                elementKind: "SectionHeaderElementKind",
		                                                                alignment: .top)
		section.boundarySupplementaryItems = [sectionHeader]
		let layout = UICollectionViewCompositionalLayout(section: section)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.bounces = false
		collectionView.backgroundColor = .mainBackground
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.register(RiseSleepCell.self, forCellWithReuseIdentifier: RiseSleepCell.cellID)
		collectionView.register(HealthAddCell.self, forCellWithReuseIdentifier: HealthAddCell.cellID)
		collectionView.register(HealthLastCell.self, forCellWithReuseIdentifier: HealthLastCell.cellID)
		collectionView.register(LinkCell.self, forCellWithReuseIdentifier: LinkCell.cellID)
		collectionView.register(FeaturedCell.self, forCellWithReuseIdentifier: FeaturedCell.cellID)
		collectionView.register(NumericProgressCell.self, forCellWithReuseIdentifier: NumericProgressCell.cellID)
		collectionView.register(HealthCell.self, forCellWithReuseIdentifier: HealthCell.cellID)
		return collectionView
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		viewModel.loadHealthData(date: selectedDate)
		viewModel.$loadingState.sink { [weak self] state in
			switch state {
			case .loading:
				DispatchQueue.main.async { [weak self] in
					self?.hud.show(in: (self?.tabBarController?.view ?? self?.view)!, animated: true)
				}
			case .completed:
				self?.hud.dismiss(animated: true)
			}
		}
		.store(in: &subscriptions)

		viewModel.$timelineItemViewModels.sink { [weak self] timelineItemViewModels in
			DispatchQueue.main.async {
				self?.addCellIndex = timelineItemViewModels.firstIndex { $0.cellType == .future }
				self?.collectionView.reloadData()
			}
		}
		.store(in: &subscriptions)

		NotificationCenter.default.publisher(for: .patientDidSnychronize)
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				self?.reload()
			}.store(in: &cancellable)
		NotificationCenter.default.publisher(for: .didUpdateCarePlan)
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				self?.reload()
			}.store(in: &cancellable)
		NotificationCenter.default.publisher(for: .didModifyHealthKitStore)
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				self?.reload()
			}.store(in: &cancellable)
		Timer.publish(every: timeInterval, tolerance: 10.0, on: .current, in: .common, options: nil)
			.autoconnect()
			.receive(on: RunLoop.main)
			.sink(receiveValue: { [weak self] _ in
				self?.reload()
			}).store(in: &cancellable)
		careManager.startUploadOutcomesTimer(timeInterval: remoteConfig.outcomesUploadTimeInterval)
		healthKitManager.authorizeHealthKit { [weak self] success, error in
			if let error = error {
				ALog.error("Unable to authorize the HealthKit", error: error)
			} else {
				ALog.info("Success result \(success)")
			}
			DispatchQueue.main.async {
				self?.reload()
			}
			self?.startBluetooth()
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "CarePlanDailyTasks"])
	}

	deinit {
		cancellable.forEach { cancellable in
			cancellable.cancel()
		}
	}

	private func setupViews() {
		view.addSubview(topView)
		topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		topView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		topView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		topView.delegate = self
		view.addSubview(collectionView)
		collectionView.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
		collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		let bottomInset: CGFloat = (tabBarController?.tabBar.frame.height)! + view.safeAreaBottom
		collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -bottomInset, right: 0)
		collectionView.delegate = self
		collectionView.dataSource = self
		view.addSubview(dateStackView)
		dateStackView.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
		dateStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		dateStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		dateStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		dateStackView.isHidden = true
		[datePicker, dateDecorationView].forEach { dateStackView.addArrangedSubview($0) }
		datePicker.addTarget(self, action: #selector(onChangeDate), for: .valueChanged)
		dateDecorationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickDecorationView)))
	}

	func reload() {
		if shouldUpdateCarePlan {
			getAndUpdateCarePlans { [weak self] _ in
				self?.viewModel.loadHealthData(date: self!.selectedDate)
			}
		} else {
			viewModel.loadHealthData(date: selectedDate)
		}
	}

	func getAndUpdateCarePlans(completion: @escaping AllieBoolCompletion) {
		guard isRefreshingCarePlan == false else {
			return
		}
		isRefreshingCarePlan = true
		hud.show(in: tabBarController?.view ?? view, animated: true)
		Task { [weak self] in
			do {
				let carePlanResponse = try await networkAPI.getCarePlan(option: .carePlan)
				if let tasks = carePlanResponse.faultyTasks, !tasks.isEmpty {
					self?.showError(tasks: tasks)
					return
				}
				careManager.process(carePlanResponse: carePlanResponse) { result in
					switch result {
					case .failure(let error):
						ALog.error("Error inserting care plan into db", error: error)
					case .success:
						ALog.info("Added new careplan to db")
					}
				}
				_ = try await careManager.process(carePlanResponse: carePlanResponse)
				self?.isRefreshingCarePlan = false
				self?.hud.dismiss(animated: true)
				completion(true)
			} catch {
				self?.isRefreshingCarePlan = false
				self?.hud.dismiss(animated: true)
				let nsError = error as NSError
				let codes: Set<Int> = [401, 404, 408, -1001]
				if !codes.contains(nsError.code) {
					ALog.error("Unable to fetch care plan", error: error)
					let okAction = AlertHelper.AlertAction(withTitle: String.ok)
					let title = NSLocalizedString("ERROR", comment: "Error")
					AlertHelper.showAlert(title: title, detailText: error.localizedDescription, actions: [okAction], from: self?.tabBarController)
				}
				completion(false)
			}
		}
	}

	func showError(tasks: [CHBasicTask]) {
		let viewController = TaskErrorDisplayViewController(style: .plain)
		viewController.items = tasks
		let navigationController = UINavigationController(rootViewController: viewController)
		tabBarController?.present(navigationController, animated: true, completion: nil)
	}

	@objc func onChangeDate(sender: UIDatePicker) {
		dateStackView.isHidden = true
		selectedDate = sender.date
		if Calendar.current.isDateInToday(sender.date) {
			topView.setButtonTitle(title: "Today")
		} else {
			let title: String = DateFormatter.yyyyMMdd.string(from: sender.date)
			topView.setButtonTitle(title: title)
		}
		viewModel.loadHealthData(date: selectedDate)
	}

	@objc func onClickDecorationView() {
		dateStackView.isHidden = true
	}
}

// MARK: - Top View Delegate

extension NewDailyTasksPageViewController: DailyTaskTopViewDelegate {
	func onClickNotGreat() {
		let viewController = FollowViewController(viewModel: viewModel, date: selectedDate)
		viewController.delegate = self
		viewController.modalTransitionStyle = .crossDissolve
		viewController.modalPresentationStyle = .overFullScreen
		present(viewController, animated: true, completion: nil)
	}

	func onClickTodayButton() {
		UIView.animate(withDuration: 0.3) {
			self.dateStackView.isHidden = false
			self.view.layoutIfNeeded()
		}
	}
}

// MARK: - FollowViewControllerDelegate

extension NewDailyTasksPageViewController: FollowViewControllerDelegate {
	func onClickDoneButton() {
		viewModel.loadHealthData(date: selectedDate)
	}
}
