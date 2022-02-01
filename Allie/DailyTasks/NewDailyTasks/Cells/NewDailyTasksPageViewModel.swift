//
//  NewDailyPageViewModel.swift
//  Allie
//
//  Created by embedded system mac on 1/31/22.
//

import Foundation
import Combine
import CareKitStore
import CareKit
import HealthKit
import CareKitUI
import UIKit

class NewDailyTasksPageViewModel: ObservableObject {
    @Published public final var taskEvents = OCKTaskEvents()
    @Published public internal(set) var error: Error?

    public let storeManager: OCKSynchronizedStoreManager
    private var cancellables: Set<AnyCancellable> = []
    private var taskCanceellables: [String: Set<AnyCancellable>] = [:]
    private var tasks: [OCKAnyTask] = [OCKAnyTask]()
    private var eventQuery: OCKEventQuery

    init(storeManager: OCKSynchronizedStoreManager, tasks: [OCKAnyTask], eventQuery: OCKEventQuery) {
        self.storeManager = storeManager
        self.tasks = tasks
        self.eventQuery = eventQuery
    }

    func fetchAndObserveEvents() {
        let ids = Array(Set(tasks.map { $0.id }))
        storeManager.fetchEventsPublisher(taskIDs: ids, query: eventQuery) { [unowned self] error in
            self.error = error
        }
        .sink { [unowned self] events in
            ids.forEach { self.taskCanceellables[$0] = nil }
            var currentViewModel = OCKTaskEvents()
            currentViewModel
                .flatMap { $0 }
                .filter { ids.contains($0.task.id) }
                .forEach { currentViewModel.remove(event: $0) }
            let modifiedEvents = events
                .flatMap { $0 }
                .map { self.modified(event: $0)}
            modifiedEvents.forEach { currentViewModel.append(event: $0) }
            self.taskEvents = currentViewModel
        }
        .store(in: &cancellables)
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

