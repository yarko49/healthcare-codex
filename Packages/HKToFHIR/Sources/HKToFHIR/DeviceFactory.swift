//
//  DeviceFactory.swift
//  Allie
//
//  Created by Waqar Malik on 3/12/21.
//

import Foundation
import HealthKit
import ModelsR4

public class DeviceFactory: BaseFactory, ResourceFactoryProtocol {
	public func resource<T>(from object: HKObject) throws -> T {
		guard T.self is ModelsR4.Device.Type else {
			throw ConversionError.incorrectTypeForFactory
		}

		let value = device(from: object) as? T
		return value!
	}

	public func device(from object: HKObject) -> ModelsR4.Device {
		ModelsR4.Device(object: object)
	}
}
