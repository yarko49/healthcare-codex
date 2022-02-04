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
    @Published var sortedTimeLineModels = [TimeLineTaskModel]()

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
            self.sortEvent(events: events)
        }
        .store(in: &cancellables)
    }

    func sortEvent(events: [[OCKAnyEvent]]) {
        var outComeValues = [OCKOutcomeValue]()
        var ockEventsDict = [Date: OCKAnyEvent]()
        for anyEvent in events {
            if anyEvent.isEmpty {
                continue
            }
            for event in anyEvent {
                if event.outcome.isNil {
                    continue
                }
                for outCome in event.outcome!.values {
                    outComeValues.append(outCome)
                    ockEventsDict[outCome.createdDate] = event
                }
            }
        }
        let sortedEventsDict = ockEventsDict.sorted(by: {
            $0.0.compare($1.0) == .orderedAscending
        })
        let sortedEvents = sortedEventsDict.map({$0.value})
        let sortedOutComeValues = outComeValues.sorted(by: { $0.createdDate.compare($1.createdDate) == .orderedAscending })
        var groupID = sortedOutComeValues.first?.healthKitUUID
        var groupOutComes = [OCKOutcomeValue]()
        var groupedOutComes = [[OCKOutcomeValue]]()
        for outCome in sortedOutComeValues {
            if groupID == outCome.healthKitUUID && outCome.healthKitUUID != nil {
                groupOutComes.append(outCome)
                continue
            } else {
                groupID = outCome.healthKitUUID
                if !groupOutComes.isEmpty {
                    groupedOutComes.append(groupOutComes)
                }
                groupOutComes.removeAll()
                groupOutComes.append(outCome)
            }
        }

        if !groupOutComes.isEmpty {
            groupedOutComes.append(groupOutComes)
        }

        var timeLineModels = [TimeLineTaskModel]()
        for index in 0..<sortedEvents.count {
            let timeLineModel = TimeLineTaskModel(
                outComes: groupedOutComes[index],
                event: sortedEvents[index]
            )
            timeLineModels.append(timeLineModel)
        }
        for anyEvent in events {
            if anyEvent.isEmpty {
                continue
            }
            var isEmptyOutCome = true
            for event in anyEvent {
                if let outCome = event.outcome, !outCome.values.isEmpty {
                    isEmptyOutCome = false
                    break
                } else {
                    isEmptyOutCome = true
                }
            }
            if isEmptyOutCome {
                let timeLineModel = TimeLineTaskModel(outComes: nil, event: anyEvent.first!)
                timeLineModels.append(timeLineModel)
            }
        }
        sortedTimeLineModels = timeLineModels
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

struct TimeLineTaskModel {
    let id: String
    let outComes: [OCKOutcomeValue]?
    let event: OCKAnyEvent

    init(outComes: [OCKOutcomeValue]?, event: OCKAnyEvent) {
        id = UUID().uuidString
        self.outComes = outComes
        self.event = event
    }
}
