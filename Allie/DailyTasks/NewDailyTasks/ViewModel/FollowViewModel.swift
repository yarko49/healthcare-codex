//
//  FollowViewModel.swift
//  Allie
//
//  Created by Onseen on 2/18/22.
//

import CareKitStore
import Combine
import Foundation

struct FollowModel {
	var isSelected: Bool
	let title: String
	let event: OCKAnyEvent

	init(isSelected: Bool, title: String, event: OCKAnyEvent) {
		self.isSelected = isSelected
		self.title = title
		self.event = event
	}
}

class FollowViewModel: ObservableObject {
	private var cancellables: Set<AnyCancellable> = []

	@Published var followModels: [FollowModel] = .init()

	init(with symptoms: [FollowModel]) {
		self.followModels = symptoms
	}

	func updateFollows(at index: Int) {
		followModels[index].isSelected.toggle()
	}
}
