//
//  Bundle+LoadData.swift
//  AllieTests
//
//  Created by Waqar Malik on 3/9/22.
//

@testable import Allie
import Foundation

extension Bundle {
	func loadTestData(fileName: String) throws -> Data {
		let components = fileName.components(separatedBy: ".")
		assert(components.count == 2)
		return try loadTestData(fileName: components[0], withExtension: components[1])
	}

	func loadTestData(fileName: String, withExtension: String) throws -> Data {
		guard let url = url(forResource: fileName, withExtension: withExtension) else {
			throw AllieError.missing("\(fileName).\(withExtension) not found")
		}
		let data = try Data(contentsOf: url)
		return data
	}
}
