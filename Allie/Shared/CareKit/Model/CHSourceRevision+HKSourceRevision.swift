//
//  CHSourceRevision+HKSourceRevision.swift
//  Allie
//
//  Created by Waqar Malik on 4/22/21.
//

import Foundation
import HealthKit

extension CHSourceRevision {
	init(sourceRevision: HKSourceRevision) {
		source = CHSource(source: sourceRevision.source)
		version = sourceRevision.version
		productType = sourceRevision.productType
		operationSystemVersion = sourceRevision.operatingSystemVersion
	}
}
