//
//  Ext_Data.swift
//  alfred-ios
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
