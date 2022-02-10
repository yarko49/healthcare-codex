//
//  Dictionary+OHQUserDataKey.swift
//  OmronKit
//
//  Created by Waqar Malik on 1/27/22.
//

import Foundation

public extension Dictionary where Key == OHQUserDataKey, Value == Any {
	/** Date of Birth(of local time zone) (Type of value : NSDate) */
	var dateOfBirth: Date? {
		get {
			self[.dateOfBirthKey] as? Date
		}
		set {
			guard let value = newValue else {
				removeValue(forKey: .dateOfBirthKey)
				return
			}
			self[.dateOfBirthKey] = value
		}
	}

	/** Height (Type of value : NSNumber[Float], Unit is ["cm"]) */
	var height: Float? {
		get {
			(self[.heightKey] as? NSNumber)?.floatValue
		}
		set {
			guard let value = newValue else {
				removeValue(forKey: .heightKey)
				return
			}
			self[.heightKey] = NSNumber(value: value)
		}
	}

	/** Gender (Type of value : OHQGender) "male", "female" */
	var gender: String? {
		get {
			self[.genderKey] as? String
		}
		set {
			guard let value = newValue else {
				removeValue(forKey: .genderKey)
				return
			}
			self[.genderKey] = value
		}
	}
}
