//
//  Notification+Names.swift
//  Allie
//
//  Created by Waqar Malik on 3/9/21.
//

import Foundation

extension Notification.Name {
	static let patientDidSnychronize = Notification.Name("patientDidSnychronize")
	static let applicationDidLogout = Notification.Name("applicationDidLogout")

	static let didRegisterOrganization = Notification.Name("didRegisterOrganization")
	static let didUnregisterOrganization = Notification.Name("didUnregisterOrganization")

	static let didPairBloodGlucoseMonitor = Notification.Name("didPairBloodGlucoseMonitor")

	static let didUpdateCarePlan = Notification.Name("didUpdateCarePlan")
	static let didModifyHealthKitStore = Notification.Name("didModifyHealthKitStore")

    static let didReceiveZendDeskNotification = Notification.Name("didReceiveZendNotification")
}
