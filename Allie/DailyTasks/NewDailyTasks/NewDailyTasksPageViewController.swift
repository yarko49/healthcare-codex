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
    private var selectedDate: Date = Date()

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
        collectionView.register(HealthFilledCell.self, forCellWithReuseIdentifier: HealthFilledCell.cellID)
        collectionView.register(HealthEmptyCell.self, forCellWithReuseIdentifier: HealthEmptyCell.cellID)
        collectionView.register(HealthAddCell.self, forCellWithReuseIdentifier: HealthAddCell.cellID)
        collectionView.register(HealthLastCell.self, forCellWithReuseIdentifier: HealthLastCell.cellID)
        collectionView.register(SimpleTaskCell.self, forCellWithReuseIdentifier: SimpleTaskCell.cellID)
        collectionView.register(LinkCell.self, forCellWithReuseIdentifier: LinkCell.cellID)
        collectionView.register(FeaturedCell.self, forCellWithReuseIdentifier: FeaturedCell.cellID)
        collectionView.register(NumericProgressCell.self, forCellWithReuseIdentifier: NumericProgressCell.cellID)
        collectionView.register(GridTaskCell.self, forCellWithReuseIdentifier: GridTaskCell.cellID)
        return collectionView
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bloodGlucoseMonitor.multicastDelegate.add(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        viewModel.loadHealthData(date: selectedDate)
        viewModel.$loadingState.sink { [weak self] state in
            switch state {
            case .loading:
                self?.hud.show(in: (self?.tabBarController?.view ?? self?.view)!, animated: true)
            case .completed:
                self?.hud.dismiss(animated: true)
            }
        }
        .store(in: &subscriptions)

        viewModel.$timelineItemViewModels.sink {[weak self] _ in
            DispatchQueue.main.async {
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

 // MARK: - Collection View Delegate & Data Source
extension NewDailyTasksPageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RiseSleepCell.cellID, for: indexPath) as! RiseSleepCell
            cell.cellType = .rise
            return cell
        } else if indexPath.row == viewModel.timelineItemViewModels.count + 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthAddCell.cellID, for: indexPath) as! HealthAddCell
            return cell
        } else if indexPath.row == viewModel.timelineItemViewModels.count + 2 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RiseSleepCell.cellID, for: indexPath) as! RiseSleepCell
            cell.cellType = .sleep
            return cell
        } else if indexPath.row == viewModel.timelineItemViewModels.count + 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthLastCell.cellID, for: indexPath) as! HealthLastCell
            return cell
        } else {
            let timelineViewModel = viewModel.timelineItemViewModels[indexPath.row - 1]
            if timelineViewModel.hasOutcomeValue() {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthFilledCell.cellID, for: indexPath) as! HealthFilledCell
                cell.configureCell(timelineViewModel: timelineViewModel)
                cell.delegate = self
                return cell
            } else {
                let taskType = timelineViewModel.timelineItemModel.event.task.groupIdentifierType
                if taskType == .simple {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SimpleTaskCell.cellID, for: indexPath) as! SimpleTaskCell
                    cell.configureCell(timelineItemViewModel: timelineViewModel)
                    return cell
                } else if taskType == .link {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LinkCell.cellID, for: indexPath) as! LinkCell
                    cell.configureCell(timelineItemViewModel: timelineViewModel)
                    return cell
                } else if taskType == .featuredContent {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedCell.cellID, for: indexPath) as! FeaturedCell
                    cell.configureCell(timelineItemViewModel: timelineViewModel)
                    return cell
                } else if taskType == .numericProgress {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NumericProgressCell.cellID, for: indexPath) as! NumericProgressCell
                    cell.configureCell(timelineItemViewModel: timelineViewModel)
                    return cell
                } else if taskType == .grid {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridTaskCell.cellID, for: indexPath) as! GridTaskCell
                    cell.configureCell(timelineItemViewModel: timelineViewModel)
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthEmptyCell.cellID, for: indexPath) as! HealthEmptyCell
                    cell.configureCell(timelineViewModel: timelineViewModel)
                    cell.delegate = self
                    return cell
                }
            }
        }
        // swiftlint:enable force_cast
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.timelineItemViewModels.count + 4
    }
}
// MARK: - Collection Cell Delegate
extension NewDailyTasksPageViewController: HealthFilledCellDelegate {
    func onClickCell(timelineItemViewModel: TimelineItemViewModel) {
        let groupIdentifierType = timelineItemViewModel.timelineItemModel.event.task.groupIdentifierType
        if groupIdentifierType == .symptoms || groupIdentifierType == .labeledValue {
            let viewController = GeneralizedLogTaskDetailViewController()
            viewController.queryDate = OCKEventQuery(for: selectedDate).dateInterval.start
            viewController.outcomeValues = timelineItemViewModel.timelineItemModel.outcomeValues ?? []
            if groupIdentifierType == .symptoms {
                guard let task = timelineItemViewModel.timelineItemModel.event.task as? OCKTask else {
                    return
                }
                viewController.anyTask = task
                viewController.outcomeIndex = 0
            } else {
                guard let task = timelineItemViewModel.timelineItemModel.event.task as? OCKHealthKitTask else {
                    return
                }
                viewController.anyTask = task
                let value = timelineItemViewModel.timelineItemModel.outcomeValues?.first
                if let uuid = value?.healthKitUUID {
                    viewController.outcome = try? careManager.dbFindFirstOutcome(uuid: uuid)
                }
            }
            viewController.modalPresentationStyle = .overFullScreen
            viewController.cancelAction = { [weak viewController] in
                viewController?.dismiss(animated: true, completion: nil)
            }
            if groupIdentifierType == .symptoms {
                viewController.outcomeValueHandler = { [weak viewController, weak self] newOutcomeValue in
                    guard let strongSelf = self, let task = (viewController?.anyTask as? OCKTask) else {
                        return
                    }
                    guard let index = viewController?.outcomeIndex, let outcome = timelineItemViewModel.timelineItemModel.event.outcome as? OCKOutcome, index < outcome.values.count else {
                        return
                    }
                    strongSelf.viewModel.updateOutcomeValue(newValue: newOutcomeValue, for: outcome, event: timelineItemViewModel.timelineItemModel.event, at: index, task: task) { result in
                        switch result {
                        case .success:
                            strongSelf.viewModel.loadHealthData(date: strongSelf.selectedDate)
                        case .failure(let error):
                            ALog.error("failed updating", error: error)
                        }
                        viewController?.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                viewController.healthKitSampleHandler = { [weak viewController, weak self] newSample in
                    guard let strongSelf = self, let outcomeValue = viewController?.outcomeValues.first, let task = (viewController?.anyTask as? OCKHealthKitTask) else {
                        return
                    }
                    strongSelf.viewModel.updateOutcome(newSample: newSample, outcomeValue: outcomeValue, task: task) { result in
                        switch result {
                        case .success:
                            strongSelf.viewModel.loadHealthData(date: strongSelf.selectedDate)
                        case .failure(let error):
                            ALog.error("Error updateing data", error: error)
                        }
                        viewController?.dismiss(animated: true, completion: nil)
                    }
                }
            }
            viewController.deleteAction = { [weak self, weak viewController] in
                if groupIdentifierType == .symptoms {
                    guard let strongSelf = self, let index = viewController?.outcomeIndex, let task = viewController?.task else {
                        viewController?.dismiss(animated: true, completion: nil)
                        return
                    }
                    do {
                        guard let eventOutcome = timelineItemViewModel.timelineItemModel.event.outcome as? OCKOutcome, index < eventOutcome.values.count else {
                            throw AllieError.missing("No Outcome Value for Event at index\(index)")
                        }
                        strongSelf.viewModel.deleteOutcomeValue(at: index, for: eventOutcome, task: task) { result in
                            switch result {
                            case .success(let deletedOutcome):
                                ALog.trace("Uploaded the outcome \(deletedOutcome.remoteId ?? "")")
                                self?.viewModel.loadHealthData(date: self?.selectedDate ?? Date())
                            case .failure(let error):
                                ALog.error("unable to upload outcome", error: error)
                            }
                            DispatchQueue.main.async {
                                viewController?.dismiss(animated: true, completion: nil)
                            }
                        }
                    } catch {
                        ALog.error("Can not delete outcome", error: error)
                        DispatchQueue.main.async {
                            viewController?.dismiss(animated: true, completion: nil)
                        }
                    }
                } else {
                    guard let outcomeValue = viewController?.outcomeValues.first, let task = viewController?.healthKitTask else {
                        viewController?.dismiss(animated: true, completion: nil)
                        return
                    }
                    self?.viewModel.deleteOutcom(value: outcomeValue, task: task, completion: { result in
                        switch result {
                        case .success(let sample):
                            self?.viewModel.loadHealthData(date: self?.selectedDate ?? Date())
                            ALog.trace("\(sample.uuid) sample was deleted", metadata: nil)
                        case .failure(let error):
                            ALog.error("Error deleting data", error: error)
                        }
                        DispatchQueue.main.async {
                            viewController?.dismiss(animated: true, completion: nil)
                        }
                    })
                }
            }
            tabBarController?.showDetailViewController(viewController, sender: self)
        } else {
            return
        }
    }
}

extension NewDailyTasksPageViewController: HealthEmptyCellDelegate {
    func onAddButtonClick(timelineItemViewModel: TimelineItemViewModel) {
        let groupIdentifierType = timelineItemViewModel.timelineItemModel.event.task.groupIdentifierType
        if groupIdentifierType == .symptoms || groupIdentifierType == .labeledValue {
            let viewController = GeneralizedLogTaskDetailViewController()
            viewController.queryDate = OCKEventQuery(for: selectedDate).dateInterval.start
            viewController.outcomeValues = []
            if groupIdentifierType == .symptoms {
                guard let task = timelineItemViewModel.timelineItemModel.event.task as? OCKTask else {
                    return
                }
                viewController.anyTask = task
                viewController.outcomeIndex = 0
            } else {
                guard let task = timelineItemViewModel.timelineItemModel.event.task as? OCKHealthKitTask else {
                    return
                }
                viewController.anyTask = task
                viewController.outcome = nil
            }
            viewController.modalPresentationStyle = .overFullScreen
            viewController.cancelAction = { [weak viewController] in
                viewController?.dismiss(animated: true, completion: nil)
            }
            if groupIdentifierType == .symptoms {
                viewController.outcomeValueHandler = { [weak viewController, weak self] newOutcomeValue in
                    guard let strongSelf = self, let task = viewController?.anyTask as? OCKTask, let carePlanId = task.carePlanId else {
                        return
                    }
                    strongSelf.viewModel.addOutcomeValue(newValue: newOutcomeValue, carePlanId: carePlanId, task: task, event: timelineItemViewModel.timelineItemModel.event) { result in
                        switch result {
                        case .failure(let error):
                            ALog.error("Error appnding outcome", error: error)
                        case .success(let outcome):
                            ALog.info("Did append value \(outcome.uuid)")
                            strongSelf.viewModel.loadHealthData(date: strongSelf.selectedDate)
                        }
                        DispatchQueue.main.async {
                            viewController?.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            } else {
                viewController.healthKitSampleHandler = { [weak viewController, weak self] newSample in
                    guard let strongSelf = self, let task = (viewController?.anyTask as? OCKHealthKitTask) else {
                        return
                    }
                    strongSelf.viewModel.addOutcome(newValue: newSample, task: task) { result in
                        switch result {
                        case .failure(let error):
                            ALog.error("unable to upload outcome", error: error)
                        case .success:
                            strongSelf.viewModel.loadHealthData(date: strongSelf.selectedDate)
                        }
                        DispatchQueue.main.async {
                            viewController?.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
            tabBarController?.showDetailViewController(viewController, sender: self)
        } else {
            return
        }
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
