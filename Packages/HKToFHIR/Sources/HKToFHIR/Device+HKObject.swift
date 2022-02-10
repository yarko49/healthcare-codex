//
//  Device+HKDevice.swift
//  Allie
//
//  Created by Waqar Malik on 3/11/21.
//

import HealthKit
import ModelsR4

public extension ModelsR4.Device {
	convenience init(object: HKObject) {
		self.init(device: object.device)
		self.identifier = [BaseFactory.identifier(system: BaseFactory.healthKitIdentifierSystemKey, value: object.sourceRevision.source.bundleIdentifier)]
		addVersions(object: object)
		addNames(object: object)
	}

	convenience init(device: HKDevice?) {
		self.init()
		self.identifier = []

		if let localIdentifer = device?.localIdentifier {
			let codeableConcept = ModelsR4.CodeableConcept()
			codeableConcept.coding = [BaseFactory.coding(system: BaseFactory.Constants.hkObjectSystemValue, code: NSExpression(forKeyPath: \HKObject.device?.localIdentifier).keyPath)]
			identifier?.append(BaseFactory.identifier(type: codeableConcept, value: localIdentifer))
		}

		if let value = device?.manufacturer {
			self.manufacturer = FHIRPrimitive<FHIRString>(stringLiteral: value)
		}

		if let name = device?.name {
			self.deviceName = [DeviceDeviceName(name: FHIRPrimitive<FHIRString>(stringLiteral: name), type: FHIRPrimitive<DeviceNameType>(.manufacturerName))]
		}

		if let model = device?.model {
			self.modelNumber = FHIRPrimitive<FHIRString>(stringLiteral: model)
		}

		addUdiDeviceIdentifier(identifier: device?.udiDeviceIdentifier)
		addVersions(device: device)
	}

	func addUdiDeviceIdentifier(identifier: String?) {
		var carrier = udiCarrier ?? []
		if let udiDeviceIdentifier = identifier {
			let udiDeviceCarrier = DeviceUdiCarrier()
			udiDeviceCarrier.entryType = FHIRPrimitive<UDIEntryType>(.selfReported)
			udiDeviceCarrier.deviceIdentifier = FHIRPrimitive<FHIRString>(stringLiteral: udiDeviceIdentifier)
			carrier.append(udiDeviceCarrier)

			udiCarrier = carrier
		}
	}

	func addVersions(object: HKObject) {
		var deviceVersions = version ?? [DeviceVersion]()

		// Add the operatingSystemVersion from the sourceRevision
		let osVersion = object.sourceRevision.operatingSystemVersion
		deviceVersions.append(Self.deviceVersion(version: "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)", system: BaseFactory.Constants.hkObjectSystemValue, code: NSExpression(forKeyPath: \HKObject.sourceRevision.operatingSystemVersion).keyPath))

		// Add the version from the sourceRevision
		if let version = object.sourceRevision.version {
			deviceVersions.append(Self.deviceVersion(version: version, system: BaseFactory.Constants.hkObjectSystemValue, code: NSExpression(forKeyPath: \HKObject.sourceRevision.version).keyPath))
		}

		version = deviceVersions
	}

	func addVersions(device: HKDevice?) {
		var deviceVersions = version ?? [DeviceVersion]()
		// Add the firmware version from the device.
		if let firmwareVersion = device?.firmwareVersion {
			deviceVersions.append(Self.deviceVersion(version: firmwareVersion, system: BaseFactory.Constants.hkObjectSystemValue, code: NSExpression(forKeyPath: \HKObject.device?.firmwareVersion).keyPath))
		}

		// Add the hardware version from the device.
		if let hardwareVersion = device?.hardwareVersion {
			deviceVersions.append(Self.deviceVersion(version: hardwareVersion, system: BaseFactory.Constants.hkObjectSystemValue, code: NSExpression(forKeyPath: \HKObject.device?.hardwareVersion).keyPath))
		}

		// Add the software version from the device.
		if let softwareVersion = device?.softwareVersion {
			deviceVersions.append(Self.deviceVersion(version: softwareVersion, system: BaseFactory.Constants.hkObjectSystemValue, code: NSExpression(forKeyPath: \HKObject.device?.softwareVersion).keyPath))
		}

		version = deviceVersions
	}

	func addNames(object: HKObject) {
		var deviceNames = deviceName ?? [DeviceDeviceName]()
		// Add the name from the source.
		deviceNames.append(DeviceDeviceName(name: FHIRPrimitive<FHIRString>(stringLiteral: object.sourceRevision.source.name), type: FHIRPrimitive<DeviceNameType>(.userFriendlyName)))

		deviceName = deviceNames
	}

	func addNames(device: HKDevice?) {
		var deviceNames = deviceName ?? [DeviceDeviceName]()
		// Add the name from the device.
		if let name = device?.name {
			deviceNames.append(DeviceDeviceName(name: FHIRPrimitive<FHIRString>(stringLiteral: name), type: FHIRPrimitive<DeviceNameType>(.modelName)))
		}
		deviceName = deviceNames
	}

	static func deviceVersion(version: String, system: String, code: String) -> DeviceVersion {
		let type = ModelsR4.CodeableConcept()
		type.coding = [BaseFactory.coding(system: BaseFactory.Constants.hkObjectSystemValue, code: code)]
		let value = FHIRPrimitive<FHIRString>(stringLiteral: version)
		return DeviceVersion(type: type, value: value)
	}
}
