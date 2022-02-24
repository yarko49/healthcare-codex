//
//  Data+PrettyPrint.swift
//  Allie
//

import Foundation
import os.log

public extension Data {
	func prettyPrint() {
		do {
			if let jsonResult = try JSONSerialization.jsonObject(with: self, options: []) as? NSDictionary {
				os_log(.info, "%@", jsonResult)
			}
		} catch {
			os_log(.error, "%@", error as NSError)
		}
	}
}
