//
//  Bundle+Version.swift
//  Allie
//
//  Created by Waqar Malik on 1/26/21.
//

import Foundation

extension Bundle {
	var ch_appVersion: String? {
		object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
	}

	var ch_buildNumber: String? {
		object(forInfoDictionaryKey: "CFBundleVersion") as? String
	}
}
