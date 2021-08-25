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

	static let didRegisterOrganization = NSNotification.Name("didRegisterOrganization")
	static let didUnregisterOrganization = NSNotification.Name("didUnregisterOrganization")

	static let didPairBloodGlucoseMonitor = NSNotification.Name("didPairBloodGlucoseMonitor")
}
