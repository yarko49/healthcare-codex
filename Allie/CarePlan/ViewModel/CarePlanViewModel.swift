//
//  CarePlanViewModel.swift
//  Allie
//
//  Created by Onseen on 2/20/22.
//

import CareKit
import CareKitStore
import CodexFoundation
import Combine
import Foundation

enum CarePlanLoadingState {
	case loading, success, failed
}

class CarePlanViewModel: ObservableObject {
	@Injected(\.networkAPI) var networkAPI: AllieAPI
	private let cancellables: Set<AnyCancellable> = []

	@Published var loadingState: CarePlanLoadingState = .loading
	@Published var carePlans: [CHTasks] = .init()

	func loadCarePlanTask() {
		loadingState = .loading
		Task {
			do {
				let carePlanResponse = try await networkAPI.getCarePlan(option: .carePlan)
				if let tasks = carePlanResponse.faultyTasks, !tasks.isEmpty {
					loadingState = .failed
					return
				}
				let tasks = carePlanResponse.tasks
				let groupedTasks = Dictionary(grouping: tasks) { (element: CHTask) in
					element.category
				}.sorted { lhs, rhs in
					let priority1 = lhs.value.first?.priority
					let priority2 = rhs.value.first?.priority
					if priority1 != nil, priority2 == nil {
						return true
					}
					if priority1 == nil, priority2 != nil {
						return false
					}
					return (lhs.value.first?.priority)! < (rhs.value.first?.priority)!
				}
				let sortedCarePlan = groupedTasks.map { _, value in
					value.sorted { lhs, rhs in
						let title1 = lhs.title
						let title2 = rhs.title
						if title1 != nil, title2 == nil {
							return true
						}
						if title1 == nil, title2 != nil {
							return false
						}
						return title1!.capitalized < title2!.capitalized
					}
				}
				self.carePlans = sortedCarePlan
				self.loadingState = .success
			} catch {
				ALog.error("Can not load care plan \(error.localizedDescription)")
				loadingState = .failed
			}
		}
	}
}
