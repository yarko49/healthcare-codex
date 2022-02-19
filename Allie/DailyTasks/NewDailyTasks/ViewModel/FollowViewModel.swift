//
//  FollowViewModel.swift
//  Allie
//
//  Created by Onseen on 2/18/22.
//

import Combine
import Foundation

struct FollowModel {
	var isSelected: Bool
	let title: String

	init(isSelected: Bool, title: String) {
		self.isSelected = isSelected
		self.title = title
	}
}

class FollowViewModel: ObservableObject {
	private var cancellables: Set<AnyCancellable> = []

	@Published var followModels: [FollowModel] = .init()

	init() {
		loadFollowData()
	}

	private func loadFollowData() {
		TempNetworkService.generateFollowData()
			.receive(on: DispatchQueue.main)
			.sink { completion in
				switch completion {
				case .finished:
					print("Finished")
				case .failure(let error):
					print("Error happened", error)
				}
			} receiveValue: { [weak self] follows in
				self?.followModels = follows
			}
			.store(in: &cancellables)
	}

	func updateFollows(at index: Int) {
		followModels[index].isSelected.toggle()
	}
}

enum TempNetworkService {
	static func generateFollowData() -> Future<[FollowModel], Error> {
		Future { promise in
			let followModels = [FollowModel(isSelected: false, title: "Nausea"), FollowModel(isSelected: false, title: "Vomiting"), FollowModel(isSelected: false, title: "Constipation"),
			                    FollowModel(isSelected: false, title: "Diarrhea"), FollowModel(isSelected: false, title: "Burning/Irritation with urination")]
			promise(.success(followModels))
		}
	}
}
