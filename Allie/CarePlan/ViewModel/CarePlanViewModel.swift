//
//  CarePlanViewModel.swift
//  Allie
//
//  Created by Onseen on 2/20/22.
//

import CareKit
import CareKitStore
import CareModel
import CodexFoundation
import Combine
import Foundation

enum CarePlanLoadingState {
	case loading, success, failed
}

class CarePlanViewModel: ObservableObject {
	@Injected(\.networkAPI) var networkAPI: AllieAPI

	private let date = Date()
	private let cancellables: Set<AnyCancellable> = []

	@Published var loadingState: CarePlanLoadingState = .loading
	@Published var carePlans: [[CHTasks]] = .init()

	func loadCarePlanTask() {
		loadingState = .loading
		Task {
			do {
				let carePlanResponse = try await networkAPI.getCarePlan(option: .carePlan)
				if let tasks = carePlanResponse.faultyTasks, !tasks.isEmpty {
					loadingState = .failed
					return
				}
				let tasks = carePlanResponse.tasks.filter { !$0.isHidden }
				let groupedTasks = Dictionary(grouping: tasks) { (element: CHTask) in
					element.category
				}.sorted { lhs, rhs in
					let priority1 = lhs.value.first?.taskPriority
					let priority2 = rhs.value.first?.taskPriority
					if priority1 != nil, priority2 == nil {
						return true
					}
					if priority1 == nil, priority2 != nil {
						return false
					}
					return (lhs.value.first?.taskPriority)! < (rhs.value.first?.taskPriority)!
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
				let carePlan = sortedCarePlan.filter { $0.first?.category != "education" && $0.first?.category != "links" }
				let recommeded = sortedCarePlan.filter { $0.first?.category == "education" || $0.first?.category == "links" }
				if !carePlan.isEmpty {
					self.carePlans.append(carePlan)
				}
				if !recommeded.isEmpty {
					self.carePlans.append(recommeded)
				}
				self.loadingState = .success
			} catch {
				ALog.error("Can not load care plan \(error.localizedDescription)")
				loadingState = .failed
			}
		}
	}
}
