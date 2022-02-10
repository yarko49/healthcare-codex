//
//  Ext_Double.swift
//  Allie
//
import Foundation

extension Double {
    
    var cleanZeroDecimal: String {
		truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
	}

}

public extension Double {

    /// Remove decimal if it equals 0, and round to two decimal places
    func removingExtraneousDecimal() -> String? {
        let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
            formatter.numberStyle = .decimal
            return formatter
        }()
        return formatter.string(from: self as NSNumber)
    }
}
