//
//  Legends.swift
//  alfred-ios
//

import Foundation
import UIKit



class Legends : Codable {
    
    
    var legend1 : String
    var legend2 : String
    var legend3 : String
    
    init(legend1 : String, legend2 : String, legend3 : String){
        
        self.legend1 = legend1
        self.legend2 = legend2
        self.legend3 = legend3
        
        
    }
    
    
    
}
