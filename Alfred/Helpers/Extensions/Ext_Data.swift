//
//  Ext_Data.swift
//  Alfred
//

import Foundation
import UIKit

extension Data {
	func prettyPrint() {
		do {
			if let jsonResult = try JSONSerialization.jsonObject(with: self, options: []) as? NSDictionary {
				print(jsonResult)
			}
		} catch {
			print(error.localizedDescription)
		}
	}
}
