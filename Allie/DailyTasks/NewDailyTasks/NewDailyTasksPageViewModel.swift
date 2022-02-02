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
    @Published public final var sortedOutComes = [[OCKOutcomeValue]]()
    @Published public final var sortedOCKEvents = [OCKAnyEvent]()
    @Published public internal(set) var error: Error?

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
            $0.0.compare($1.0) == .orderedDescending
        })
        let sortedEvents = sortedEventsDict.map({$0.value})
        let sortedOutComeValues = outComeValues.sorted(by: { $0.createdDate.compare($1.createdDate) == .orderedDescending })
        var groupID = sortedOutComeValues.first?.healthKitUUID
        var groupOutComes = [OCKOutcomeValue]()
        var groupedOutComes = [[OCKOutcomeValue]]()
        for outCome in sortedOutComeValues {
            if groupID == outCome.healthKitUUID && outCome.healthKitUUID != nil {
                groupOutComes.append(outCome)
                continue
            } else {
                groupID = outCome.healthKitUUID
                if groupOutComes.count > 0 {
                    groupedOutComes.append(groupOutComes)
                }
                groupOutComes.removeAll()
                groupOutComes.append(outCome)
            }
        }
        
        if groupOutComes.count > 0 {
            groupedOutComes.append(groupOutComes)
        }
        sortedOCKEvents = sortedEvents
        sortedOutComes = groupedOutComes
    }

    func modified(event: OCKAnyEvent) -> OCKAnyEvent {
        return event
    }

    func clearSubscriptions() {
        cancellables = []
        taskCanceellables = [:]
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
