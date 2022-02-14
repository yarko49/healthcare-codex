//
//  NewDailyTasksPageViewController.swift
//  Allie
//
//  Created by Onseen on 1/25/22.
//
import AscensiaKit
import UIKit
import JGProgressHUD
import Combine
import CareKitStore
import CareKit
import SwiftUI
import BluetoothService
import CodexFoundation

class NewDailyTasksPageViewController: BaseViewController {

    @Injected(\.careManager) var careManager: CareManager
    @Injected(\.healthKitManager) var healthKitManager: HealthKitManager
    @Injected(\.networkAPI) var networkAPI: AllieAPI
    @Injected(\.bluetoothService) var bluetoothService: BluetoothService
    @Injected(\.remoteConfig) var remoteConfig: RemoteConfigManager
    var bluetoothDevices: [UUID: AKDevice] = [:]
    var addCellIndex: Int?

    @ObservedObject var viewModel: NewDailyTasksPageViewModel = NewDailyTasksPageViewModel()

    var timeInterval: TimeInterval = 60 * 10
    var cancellable: Set<AnyCancellable> = []
    private var shouldUpdateCarePlan: Bool = true
    private var insertViewsAnimated: Bool = true
    private var isRefreshingCarePlan = false
    var ockTasks: [OCKAnyTask] = [OCKAnyTask]()
    var selectedDate: Date = Date()

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bluetoothService.addDelegate(self)
    }

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

        viewModel.$timelineItemViewModels.sink {[weak self] timelineItemViewModels in
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
        if careManager.patient?.bgmName == nil {
            NotificationCenter.default.publisher(for: .didPairBloodGlucoseMonitor)
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in
                    self?.startBluetooth()
                }.store(in: &cancellable)
        }
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
            if self?.careManager.patient?.bgmName != nil {
                self?.startBluetooth()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsManager.send(event: .pageView, properties: [.name: "CarePlanDailyTasks"])
    }

    deinit {
        bluetoothService.removeDelegate(self)
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
        let bottomInset: CGFloat = (self.tabBarController?.tabBar.frame.height)! + self.view.safeAreaBottom
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -bottomInset, right: 0)
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
            getAndUpdateCarePlans { [weak self] _ in
                self?.viewModel.loadHealthData(date: self!.selectedDate)
            }
        } else {
            self.viewModel.loadHealthData(date: self.selectedDate)
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
        selectedDate = sender.date
        if Calendar.current.isDateInToday(sender.date) {
            topView.setButtonTitle(title: "Today")
        } else {
            let title: String = DateFormatter.yyyyMMdd.string(from: sender.date)
            topView.setButtonTitle(title: title)
        }
        viewModel.loadHealthData(date: selectedDate)
    }
}

 // MARK: - Top View Delegate
extension NewDailyTasksPageViewController: DailyTaskTopViewDelegate {
    func onClickTodayButton() {
        UIView.animate(withDuration: 0.3) {
            self.datePicker.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
}
