//
//  NewDailyTasksPageViewController.swift
//  Allie
//
//  Created by Onseen on 1/25/22.
//

import UIKit
import JGProgressHUD
import Combine
import CareKitStore
import CareKit
import SwiftUI

class NewDailyTasksPageViewController: BaseViewController {

    @Injected(\.careManager) var careManager: CareManager
    @Injected(\.healthKitManager) var healthKitManager: HealthKitManager
    @Injected(\.networkAPI) var networkAPI: AllieAPI
    @Injected(\.bluetoothManager) var bloodGlucoseMonitor: BGMBluetoothManager
    @Injected(\.remoteConfig) var remoteConfig: RemoteConfigManager

    @ObservedObject var viewModel: NewDailyTasksPageViewModel = NewDailyTasksPageViewModel()

    var timeInterval: TimeInterval = 60 * 10
    var cancellable: Set<AnyCancellable> = []
    private var shouldUpdateCarePlan: Bool = true
    private var insertViewsAnimated: Bool = true
    private var isRefreshingCarePlan = false
    var ockTasks: [OCKAnyTask] = [OCKAnyTask]()

    private var subscriptions = Set<AnyCancellable>()

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        datePicker.setValue(UIColor.white, forKey: "backgroundColor")
        return datePicker
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        section.interGroupSpacing = 0
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .absolute(0))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize,
                                                                        elementKind: "SectionHeaderElementKind",
                                                                        alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]
        let layout = UICollectionViewCompositionalLayout(section: section)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .mainBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(RiseSleepCell.self, forCellWithReuseIdentifier: RiseSleepCell.cellID)
        collectionView.register(HealthFilledCell.self, forCellWithReuseIdentifier: HealthFilledCell.cellID)
        collectionView.register(HealthEmptyCell.self, forCellWithReuseIdentifier: HealthEmptyCell.cellID)
        collectionView.register(HealthAddCell.self, forCellWithReuseIdentifier: HealthAddCell.cellID)
        collectionView.register(HealthLastCell.self, forCellWithReuseIdentifier: HealthLastCell.cellID)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bloodGlucoseMonitor.multicastDelegate.add(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        viewModel.loadHealthData(date: Date())
        viewModel.$sortedOutComes.sink {[weak self] outComes in
            DispatchQueue.main.async {
                let events = self!.viewModel.sortedOCKEvents
                print(events.count)
                self?.collectionView.reloadData()
            }
        }
        .store(in: &subscriptions)
//        NotificationCenter.default.publisher(for: .patientDidSnychronize)
//            .receive(on: RunLoop.main)
//            .sink { [weak self] _ in
//                self?.reload()
//            }.store(in: &cancellable)
//        NotificationCenter.default.publisher(for: .didUpdateCarePlan)
//            .receive(on: RunLoop.main)
//            .sink { [weak self] _ in
//                self?.reload()
//            }.store(in: &cancellable)
//        NotificationCenter.default.publisher(for: .didModifyHealthKitStore)
//            .receive(on: RunLoop.main)
//            .sink { [weak self] _ in
//                self?.setupViews()
//            }.store(in: &cancellable)
        if careManager.patient?.bgmName == nil {
            NotificationCenter.default.publisher(for: .didPairBloodGlucoseMonitor)
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in
                    self?.startBluetooth()
                }.store(in: &cancellable)
        }
//        Timer.publish(every: timeInterval, tolerance: 10.0, on: .current, in: .common, options: nil)
//            .autoconnect()
//            .receive(on: RunLoop.main)
//            .sink(receiveValue: { [weak self] _ in
//                self?.reload()
//            }).store(in: &cancellable)
//        careManager.startUploadOutcomesTimer(timeInterval: remoteConfig.outcomesUploadTimeInterval)
//        healthKitManager.authorizeHealthKit { [weak self] success, error in
//            if let error = error {
//                ALog.error("Unable to authorize the HealthKit", error: error)
//            } else {
//                ALog.info("Success result \(success)")
//            }
//            DispatchQueue.main.async {
//                self?.reload()
//            }
//            if self?.careManager.patient?.bgmName != nil {
//                self?.startBluetooth()
//            }
//        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsManager.send(event: .pageView, properties: [.name: "CarePlanDailyTasks"])
    }

    deinit {
        bloodGlucoseMonitor.multicastDelegate.remove(self)
        cancellable.forEach { cancellable in
            cancellable.cancel()
        }
    }

    private func setupViews() {
        view.addSubview(topView)
        topView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor).isActive = true
        topView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        topView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        topView.delegate = self
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(datePicker)
        datePicker.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        datePicker.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        datePicker.isHidden = true
        datePicker.addTarget(self, action: #selector(onChangeDate), for: .valueChanged)
    }

    func reload() {
        if shouldUpdateCarePlan {
            getAndUpdateCarePlans { _ in
                self.collectionView.reloadData()
            }
        } else {
            self.collectionView.reloadData()
        }
    }

    func getAndUpdateCarePlans(completion: @escaping AllieBoolCompletion) {
        guard isRefreshingCarePlan == false else {
            return
        }
        isRefreshingCarePlan = true
        hud.show(in: tabBarController?.view ?? view, animated: true)
        Task {
            do {
                let carePlanResponsee = try await networkAPI.getCarePlan(option: .carePlan)
                if let tasks = carePlanResponsee.faultyTasks, !tasks.isEmpty {
                    self.showError(tasks: tasks)
                    return
                }
                _ = try await careManager.process(carePlanResponse: carePlanResponsee)
                self.isRefreshingCarePlan = false
                DispatchQueue.main.async {
                    self.hud.dismiss(animated: true)
                }
                completion(true)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.isRefreshingCarePlan = false
                    self?.hud.dismiss(animated: true)
                    let nsError = error as NSError
                    let code: Set<Int> = [401, 408, -1001]
                    if !code.contains(nsError.code) {
                        ALog.error("Unable to fetch care plan", error: error)
                        let okAction = AlertHelper.AlertAction(withTitle: String.ok)
                        let title = NSLocalizedString("ERROR", comment: "Error")
                        AlertHelper.showAlert(title: title, detailText: error.localizedDescription, actions: [okAction], from: self?.tabBarController)
                    }
                    completion(false)
                }
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
        datePicker.isHidden = true
    }
}

 // MARK: - Collection View Delegate & Data Source
extension NewDailyTasksPageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RiseSleepCell.cellID, for: indexPath) as! RiseSleepCell
            cell.cellType = .rise
            return cell
        } else if indexPath.row == viewModel.sortedOutComes.count + 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthEmptyCell.cellID, for: indexPath) as! HealthEmptyCell
            cell.configureCell(cellType: .glucose)
            return cell
        } else if indexPath.row == viewModel.sortedOutComes.count + 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthEmptyCell.cellID, for: indexPath) as! HealthEmptyCell
            cell.configureCell(cellType: .insulin)
            return cell
        } else if indexPath.row == viewModel.sortedOutComes.count + 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthEmptyCell.cellID, for: indexPath) as! HealthEmptyCell
            cell.configureCell(cellType: .asprin)
            return cell
        } else if indexPath.row == viewModel.sortedOutComes.count + 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthAddCell.cellID, for: indexPath) as! HealthAddCell
            return cell
        } else if indexPath.row == viewModel.sortedOutComes.count + 5 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RiseSleepCell.cellID, for: indexPath) as! RiseSleepCell
            cell.cellType = .sleep
            return cell
        } else if indexPath.row == viewModel.sortedOutComes.count + 6 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthLastCell.cellID, for: indexPath) as! HealthLastCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthFilledCell.cellID, for: indexPath) as! HealthFilledCell
            cell.configureCell(outComes: viewModel.sortedOutComes[indexPath.row - 1], ockEvent: viewModel.sortedOCKEvents[indexPath.row - 1])
            return cell
        }
        // swiftlint:enable force_cast
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.sortedOutComes.count + 7
    }
}

 // MARK: - Top View Delegate
extension NewDailyTasksPageViewController: DailyTaskTopViewDelegate {
    func onClickTodayButton() {
        UIView.animate(withDuration: 0.3) {
            self.datePicker.isHidden = false
        }
    }
}
