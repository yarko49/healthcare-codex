//
//  ConversionError.swift
//  Allie
//
//  Created by Waqar Malik on 3/12/21.
//

import Foundation

public enum ConversionError: Error {
	case conversionNotDefinedForType(identifier: String)
	case requiredConversionValueMissing(key: String)
	case unsupportedType(identifier: String)
	case dateConversionError
	case incorrectTypeForFactory
}
