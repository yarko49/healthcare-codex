//
//  DevicesModel.swift
//  alfred-ios
//

import Foundation

enum DevicesSettings: CustomStringConvertible {
    case smartScale
    case smartBlockPressureCuff
    case smartWatch
    case smartPedometer
    case none
    
    var description : String {
        switch self {
        case .smartScale:
            return Str.smartScale
        case .smartBlockPressureCuff:
            return Str.smartBlockPressureCuff
        case .smartWatch:
            return Str.smartWatch
        case .smartPedometer:
            return Str.smartPedometer
        case .none:
            return ""
        }
    }
    
static let allValues = [smartScale, smartBlockPressureCuff, smartPedometer]
}
