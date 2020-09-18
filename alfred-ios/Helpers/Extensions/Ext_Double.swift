//
//  Ext_Double.swift
//  alfred-ios
//

extension Double {
    var cleanZeroDecimal: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
