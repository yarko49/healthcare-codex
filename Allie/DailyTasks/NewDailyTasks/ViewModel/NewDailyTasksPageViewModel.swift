//
//  NewDailyPageViewModel.swift
//  Allie
//
//  Created by Onseen on 1/31/22.
//

import Foundation
import Combine
import CareKitStore
import CareKit
import HealthKit
import CareKitUI
import UIKit

class NewDailyTasksPageViewModel: ObservableObject {
    @Injected(\.careManager) var careManager: CareManager
    @Injected(\.healthKitManager) var healthKitManager: HealthKitManager
    @Published public internal(set) var error: Error?
    @Published var timelineItemViewModels = [TimelineItemViewModel]()

    public let storeManager: OCKSynchronizedStoreManager = CareManager.shared.synchronizedStoreManager
    private var cancellables: Set<AnyCancellable> = []
    private var taskCanceellables: [String: Set<AnyCancellable>] = [:]

    func loadHealthData(date: Date) {
        var query = OCKTaskQuery(for: date)
        query.excludesTasksWithNoEvents = true
        storeManager.store.fetchAnyTasks(query: query, callbackQueue: .main) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .failure(let error):
                ALog.error("Fetching tasks for care plans", error: error)
            case .success(let tasks):
                let filtered = tasks.filter { task in
                    if let chTask = self.careManager.tasks[task.id] {
                        return !chTask.isDeleted(for: date) && task.schedule.exists(onDay: date)
                    } else if let ockTask = task as? OCKTask {
                        return !ockTask.isDeleted(for: date) && task.schedule.exists(onDay: date)
                    } else if let hkTask = task as? OCKHealthKitTask, let deletedDate = hkTask.deletedDate {
                        return deletedDate.shouldShow(for: date)
                    } else {
                        return true
                    }
                }
                let sorted = filtered.sorted { lhs, rhs in
                    guard let left = lhs as? AnyTaskExtensible, let right = rhs as? AnyTaskExtensible else {
                        return false
                    }
                    return left.priority < right.priority
                }
                self.fetchAndObserveEvents(tasks: sorted, query: OCKEventQuery(for: date))
            }
        }
    }

    func fetchAndObserveEvents(tasks: [OCKAnyTask], query: OCKEventQuery) {
        let ids = Array(Set(tasks.map { $0.id }))
        storeManager.fetchEventsPublisher(taskIDs: ids, query: query) { [unowned self] error in
            self.error = error
        }
        .sink { [unowned self] events in
            self.generateTimelineItems(events: events)
        }
        .store(in: &cancellables)
    }

    func generateTimelineItems(events: [[OCKAnyEvent]]) {
        var items = [TimelineItemViewModel]()
        for taskEvent in events {
            var flag = false
            for event in taskEvent {
                if let outcomes = event.outcome {
                    if !outcomes.values.isEmpty {
                        var outcomeArr = [OCKOutcomeValue]()
                        var healthKitUUID = outcomes.values.first?.healthKitUUID
                        for outcome in outcomes.values {
                            if outcome.healthKitUUID == healthKitUUID && outcome.healthKitUUID != nil {
                                outcomeArr.append(outcome)
                                continue
                            } else {
                                healthKitUUID = outcome.healthKitUUID
                                if !outcomeArr.isEmpty {
                                    items.append(TimelineItemViewModel(timelineItemModel: TimelineItemModel(outcomeValues: outcomeArr, event: event)))
                                }
                                outcomeArr.removeAll()
                                outcomeArr.append(outcome)
                            }
                        }
                        items.append(TimelineItemViewModel(timelineItemModel: TimelineItemModel(outcomeValues: outcomeArr, event: event)))
                    } else if !flag {
                        let timelineItemModel = TimelineItemModel(outcomeValues: nil, event: event)
                        items.append(TimelineItemViewModel(timelineItemModel: timelineItemModel))
                        flag = true
                    }
                } else if !flag {
                    let timelineItemModel = TimelineItemModel(outcomeValues: nil, event: event)
                    items.append(TimelineItemViewModel(timelineItemModel: timelineItemModel))
                    flag = true
                }
            }
        }

       timelineItemViewModels = items.sorted { lhs, rhs in
            let date1 = lhs.dateTime
            let date2 = rhs.dateTime
            if lhs.hasOutcomeValue() && !rhs.hasOutcomeValue() {
                return true
            }
            if !lhs.hasOutcomeValue() && rhs.hasOutcomeValue() {
                return false
            }
            return date1.compare(date2) == .orderedAscending
        }
    }

    func modified(event: OCKAnyEvent) -> OCKAnyEvent {
        return event
    }

    func clearSubscriptions() {
        cancellables = []
        taskCanceellables = [:]
    }

    func deleteOutcom(value: OCKOutcomeValue, task: OCKHealthKitTask, completion: @escaping AllieResultCompletion<CHOutcome>) {
        deleteOutcome(value: value) { [weak self] result in
            switch result {
            case .success(let sample):
                ALog.trace("Did delete sample \(sample.uuid)", metadata: nil)
                do {
                    var outcome: CHOutcome?
                    if let carePlanId = task.carePlanId {
                        outcome = self?.careManager.fetchOutcome(sample: sample, deletedSample: sample, task: task, carePlanId: carePlanId)
                    } else {
                        outcome = try self?.careManager.dbFindFirstOutcome(sample: sample)
                    }
                    guard var existingOutcome = outcome else {
                        throw AllieError.missing("\(sample.uuid.uuidString)")
                    }
                    existingOutcome.deletedDate = Date()
                    self?.careManager.upload(outcomes: [existingOutcome], completion: { result in
                        if case .failure(let error) = result {
                            ALog.error("unable to upload outcome", error: error)
                        }
                        completion(.success(existingOutcome))
                    })
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                ALog.error("Error deleteing data", error: error)
            }
        }
    }

    func deleteOutcome(value: OCKOutcomeValue, completion: AllieResultCompletion<HKSample>?) {
        guard let uuid = value.healthKitUUID, let identifier = value.quantityIdentifier else {
            completion?(.failure(AllieError.invalid("Invalid outcome value")))
            return
        }
        if identifier == HKQuantityTypeIdentifier.bloodPressureSystolic.rawValue || identifier ==
            HKQuantityTypeIdentifier.bloodPressureDiastolic.rawValue {
            guard let bloodPressureType = HKCorrelationType.correlationType(forIdentifier: .bloodPressure) else {
                completion?(.failure(HealthKitManagerError.invalidInput("Invalid quantityIdentifier")))
                return
            }
            healthKitManager.deleteCorrelationSample(uuid: uuid, sampleType: bloodPressureType, completion: completion)
        } else {
            healthKitManager.delete(uuid: uuid, quantityIdentifier: identifier, completion: completion)
        }
    }
}

extension OCKSynchronizedStoreManager {
    func fetchEventsPublisher(taskIDs: [String], query: OCKEventQuery, errorHandler: ((OCKStoreError) -> Void)?) -> AnyPublisher<[[OCKAnyEvent]], Never> {
        let publishers = taskIDs.map { id in
            fetchAnyEventsPublisher(taskID: id, query: query)
                .catch { error -> Empty<[OCKAnyEvent], Never> in
                    errorHandler?(error)
                    return .init()
                }
        }
        return Publishers.Sequence(sequence: publishers)
            .flatMap { $0 }
            .collect()
            .eraseToAnyPublisher()
    }

    func fetchAnyEventsPublisher(taskID: String, query: OCKEventQuery) -> AnyPublisher<[OCKAnyEvent], OCKStoreError> {
        Future { [unowned self] completion in
            self.store.fetchAnyEvents(taskID: taskID, query: query, callbackQueue: .main, completion: completion)
        }
        .eraseToAnyPublisher()
    }
}
