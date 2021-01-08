//
//  Ext_Data.swift
//  Alfred
//

import Foundation

extension Data {
	func prettyPrint() {
		do {
			if let jsonResult = try JSONSerialization.jsonObject(with: self, options: []) as? NSDictionary {
				ALog.info("\(jsonResult)")
			}
		} catch {
			ALog.error("\(error.localizedDescription)")
		}
	}
}
