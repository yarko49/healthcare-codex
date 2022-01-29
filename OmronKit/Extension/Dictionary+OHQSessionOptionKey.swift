//
//  Dictionary+OHQSessionOptionKey.swift
//  OmronKit
//
//  Created by Waqar Malik on 1/27/22.
//

import Foundation

public extension Dictionary where Key == OHQSessionOptionKey, Value == Any {
	/** Read Measurement Records (Type of value : NSNumber[BOOL])
	 A Boolean value that specifies whether reading records of measurement.
	 The value for this key is an NSNumber object. If the key is not specified, the default value is NO.
	 */
	var readMeasurementRecords: Bool? {
		get {
			(self[.readMeasurementRecordsKey] as? NSNumber)?.boolValue
		}
		set {
			guard let value = newValue else {
				removeValue(forKey: .readMeasurementRecordsKey)
				return
			}
			self[.readMeasurementRecordsKey] = NSNumber(value: value)
		}
	}

	/** Allow Control of Reading Position to Measurement Records (Type of value : NSNumber[BOOL])
	 A boolean value that specifies whether to control the reading position of the measurement record.
	 If you specify YES, the reading position of the measurement record depends on the value specified by SequenceNumberOfFirstRecordToReadKey.
	 If SequenceNumberOfFirstRecordToReadKey is not specifed, all records are read.
	 It works only on devices that support the Omron Extension protocol.
	 The value for this key is an NSNumber object. If the key is not specified, the default value is NO.
	 */
	var allowControlOfReadingPositionToMeasurementRecords: Bool? {
		get {
			(self[.allowControlOfReadingPositionToMeasurementRecordsKey] as? NSNumber)?.boolValue
		}
		set {
			guard let value = newValue else {
				removeValue(forKey: .allowControlOfReadingPositionToMeasurementRecordsKey)
				return
			}
			self[.allowControlOfReadingPositionToMeasurementRecordsKey] = NSNumber(value: value)
		}
	}

	/** Sequence Number of First Record to Read (Type of value : NSNumber[0 - 65535])
	 A sequence number that specifies the reading start position for measurement record.
	 It works only on devices that support the Omron Extension protocol.
	 */
	var sequenceNumberOfFirstRecordToRead: Int? {
		get {
			(self[.sequenceNumberOfFirstRecordToReadKey] as? NSNumber)?.intValue
		}
		set {
			guard let value = newValue else {
				removeValue(forKey: .sequenceNumberOfFirstRecordToReadKey)
				return
			}
			self[.sequenceNumberOfFirstRecordToReadKey] = NSNumber(value: value)
		}
	}

	/** Allow Access to Omron Extended Measurement Records (Type of value : NSNumber[BOOL])
	 A Boolean value that specifies whether reading omron extended measurement records instead of bluetooth standard measurement record.
	 It works only on devices that support the Omron Extension protocol.
	 The value for this key is an NSNumber object. If the key is not specified, the default value is NO.
	 */
	var allowAccessToOmronExtendedMeasurementRecords: Bool? {
		get {
			(self[.allowAccessToOmronExtendedMeasurementRecordsKey] as? NSNumber)?.boolValue
		}
		set {
			guard let value = newValue else {
				removeValue(forKey: .allowAccessToOmronExtendedMeasurementRecordsKey)
				return
			}
			self[.allowAccessToOmronExtendedMeasurementRecordsKey] = NSNumber(value: value)
		}
	}

	/** Register New User (Type of value : NSNumber[BOOL])
	 A Boolean value that specifies whether register new user to device.
	 If the user index is not specified with UserIndexKey, it is assigned to an unregistered user index, and if it is specified, it is assigned to the specified User Index.
	 You can specify the User Index only on devices that support Omron Extension Protocol.
	 If registration fails, the session will fail with the reason of FailedToRegisterUser.
	 It works only on devices that manage users.
	 The value for this key is an NSNumber object. If the key is not specified, the default value is NO.
	 */
	var registerNewUser: Bool? {
		get {
			(self[.registerNewUserKey] as? NSNumber)?.boolValue
		}
		set {
			guard let value = newValue else {
				removeValue(forKey: .registerNewUserKey)
				return
			}
			self[.registerNewUserKey] = NSNumber(value: value)
		}
	}

	/** Delete User Data (Type of value : NSNumber[BOOL])
	 A Boolean value that specifies whether delete user data from device.
	 If you specify YES, the user information registered in the User Index specified by UserIndexKey is deleted.
	 If deletion fails, the session will fail with the reason of FailedToDeleteUser.
	 It works only with devices that manage users.
	 The value for this key is an NSNumber object. If the key is not specified, the default value is NO.
	 */
	var deleteUserData: Bool? {
		get {
			(self[.deleteUserDataKey] as? NSNumber)?.boolValue
		}
		set {
			guard let value = newValue else {
				removeValue(forKey: .deleteUserDataKey)
				return
			}
			self[.deleteUserDataKey] = NSNumber(value: value)
		}
	}

	/** Consent Code (Type of value : NSNumber[0x0000 - 0x270F])
	 Consent code used for user authentication and user registration.
	 This only works if UserIndexKey is specified.
	 The value for this key is an NSNumber object. If the key is not specified, the default value is OHQDefaultConsentCode(0x020E).
	 */
	var consentCode: UInt? {
		get {
			(self[.consentCodeKey] as? NSNumber)?.uintValue
		}
		set {
			guard let value = newValue else {
				removeValue(forKey: .consentCodeKey)
				return
			}
			self[.consentCodeKey] = NSNumber(value: value)
		}
	}

	/** User Index (Type of value : NSNumber[1 - 4])
	 User index used for user authentication and user registration.
	 It works only with devices that manage users.
	 */
	var userIndex: Int? {
		get {
			(self[.userIndexKey] as? NSNumber)?.intValue
		}
		set {
			guard let value = newValue else {
				removeValue(forKey: .userIndexKey)
				return
			}
			self[.userIndexKey] = NSNumber(value: value)
		}
	}

	/** User Data (Type of value : NSDictionary<OHQUserDataKey,id>) */
	var userData: [OHQUserDataKey: Any]? {
		get {
			self[.userDataKey] as? [OHQUserDataKey: Any]
		}
		set {
			guard let value = newValue else {
				removeValue(forKey: .userDataKey)
				return
			}
			self[.userDataKey] = value
		}
	}

	/** Database Change Increment Value (Type of value : NSNumber[0 - 4294967295]) */
	var databaseChangeIncrementValue: UInt? {
		get {
			(self[.databaseChangeIncrementValueKey] as? NSNumber)?.uintValue
		}
		set {
			guard let value = newValue else {
				removeValue(forKey: .databaseChangeIncrementValueKey)
				return
			}
			self[.databaseChangeIncrementValueKey] = NSNumber(value: value)
		}
	}

	/** User Data Update Flag (Type of value : NSNumber[BOOL]) */
	var userDataUpdateFlag: Bool? {
		get {
			(self[.userDataUpdateFlagKey] as? NSNumber)?.boolValue
		}
		set {
			guard let value = newValue else {
				removeValue(forKey: .userDataUpdateFlagKey)
				return
			}
			self[.userDataUpdateFlagKey] = NSNumber(value: value)
		}
	}

	/** Connection Wait Time (Type of value : NSNumber[NSTimeInterval]) */
	var connectionWaitTime: TimeInterval? {
		get {
			(self[.connectionWaitTimeKey] as? NSNumber)?.doubleValue
		}
		set {
			guard let value = newValue else {
				removeValue(forKey: .connectionWaitTimeKey)
				return
			}
			self[.connectionWaitTimeKey] = NSNumber(value: value)
		}
	}
}
