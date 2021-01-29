//
//  Ext_Double.swift
//  Alfred
//

extension Double {
	var cleanZeroDecimal: String {
		truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
	}
}
