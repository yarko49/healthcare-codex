//
//  ConfigurationError.swift
//  Allie
//
//  Created by Waqar Malik on 3/12/21.
//

import Foundation

public enum ConfigurationError: Error {
	case defaultConfigurationBundleNotFound
	case defaultConfigurationNotFound
	case invalidDefaultConfiguration
	case configurationNotFound
	case invalidConfiguration
}
