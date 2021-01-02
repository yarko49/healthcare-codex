//
//  Ext_Data.swift
//  Alfred
//

import Foundation
import os.log

extension Data {
	func prettyPrint() {
		do {
			if let jsonResult = try JSONSerialization.jsonObject(with: self, options: []) as? NSDictionary {
				Logger.alfred.info("\(jsonResult)")
			}
		} catch {
			Logger.alfred.error("\(error.localizedDescription)")
		}
	}
}
