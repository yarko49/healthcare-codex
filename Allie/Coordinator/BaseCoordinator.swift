//
//  BaseCoordinator.swift
//  Allie
//
//  Created by Waqar Malik on 5/24/21.
//

import CodexFoundation
import Combine
import Firebase
import FirebaseAuth
import KeychainAccess
import UIKit

class BaseCoordinator: NSObject, Coordinable, UIViewControllerTransitioningDelegate {
	let type: CoordinatorType
	var navigationController: UINavigationController?
	@Injected(\.networkAPI) var networkAPI: AllieAPI
	@Injected(\.careManager) var careManager: CareManager
	@Injected(\.healthKitManager) var healthKitManager: HealthKitManager
	@Injected(\.keychain) var keychain: Keychain

	var rootViewController: UIViewController? {
		nil
	}

	var childCoordinators: [CoordinatorType: Coordinable] = [:]
	var cancellables: Set<AnyCancellable> = []

	func start() {}

	var appCoordinator: AppCoordinator? {
		childCoordinators[.application] as? AppCoordinator
	}

	var authCoordinator: AuthCoordinator? {
		childCoordinators[.authentication] as? AuthCoordinator
	}

	init(type: CoordinatorType) {
		self.type = type
	}

	deinit {
		cancellables.forEach { cancellable in
			cancellable.cancel()
		}
		cancellables.removeAll()
	}

	func resetAll() {
		let firebaseAuth = Auth.auth()
		do {
			try firebaseAuth.signOut()
			UserDefaults.standard.resetUserDefaults()
			careManager.reset()
			keychain.clearKeychain()
		} catch let signOutError as NSError {
			ALog.error("Error signing out:", error: signOutError)
		}
	}

	func uploadPatient(patient: CHPatient) {
		networkAPI.post(patient: patient)
			.receive(on: DispatchQueue.main)
			.sink { completion in
				switch completion {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
					AlertHelper.showAlert(title: String.error, detailText: String.createPatientFailed, actions: [AlertHelper.AlertAction(withTitle: String.ok)], from: self.navigationController)
				case .finished:
					break
				}
			} receiveValue: { _ in
				ALog.info("OK STATUS FOR PATIENT : 200")
			}.store(in: &cancellables)
	}

	func resetDataIfNeeded(newPatientId: String, force: Bool = false) -> Bool {
		// Patient does not exist, no need to reset
		guard let existingPatientId = careManager.patient?.id, !existingPatientId.isEmpty else {
			return false
		}

		// if the current patient is same the new patient, no need to reset
		guard newPatientId != existingPatientId else {
			return false
		}

		// newPatientId and existingPatientId do not match, reset the data
		resetAll()
		ALog.info("Did clear the patient data for existing UID \(existingPatientId), newUser id = \(newPatientId)")
		return true
	}
}
