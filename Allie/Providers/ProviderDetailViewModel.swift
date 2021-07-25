//
//  ProviderDetailViewModel.swift
//  Allie
//
//  Created by Waqar Malik on 6/27/21.
//

import Combine
import Foundation

class ProviderDetailViewModel: ObservableObject {
	private var cancellables: Set<AnyCancellable> = []
	private(set) var organization: CHOrganization
	@Published var isRegistered: Bool = false
	var shouldShowAlert = false

	init(organization: CHOrganization) {
		self.organization = organization
	}

	func register(completion: @escaping AllieBoolCompletion) {
		APIClient.shared.registerOrganization(organization: organization)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] result in
				self?.isRegistered = result
				NotificationCenter.default.post(name: .didRegisterOrganization, object: nil, userInfo: nil)
				ALog.info("Did finish registration \(result)")
			}.store(in: &cancellables)
	}

	func unregister(completion: @escaping AllieBoolCompletion) {
		APIClient.shared.unregisterOrganization(organization: organization)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] result in
				self?.isRegistered = !result
				NotificationCenter.default.post(name: .didUnregisterOrganization, object: nil, userInfo: nil)
				ALog.info("Did finish unregister \(result)")
				completion(result)
			}.store(in: &cancellables)
	}
}
