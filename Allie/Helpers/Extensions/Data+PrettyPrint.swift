//
//  Ext_Data.swift
//  Allie
//

import Foundation

extension Data {
	func prettyPrint() {
		do {
			if let jsonResult = try JSONSerialization.jsonObject(with: self, options: []) as? NSDictionary {
				ALog.info("\(jsonResult)")
			}
		} catch {
			ALog.error(error: error)
		}
	}
}
