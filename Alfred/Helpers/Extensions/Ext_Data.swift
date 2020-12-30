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
				os_log(.info, log: .alfred, "%@", jsonResult)
			}
		} catch {
			os_log(.error, log: .alfred, "%@", error.localizedDescription)
		}
	}
}
