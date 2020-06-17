//
//  Colors.swift
//  alfred-ios


import Foundation
import UIKit
import Charts


class Colors : NSObject {
    
    
    func coloring(entry : Double) -> NSUIColor {
        
        if entry < 3.0 {
            
            return NSUIColor.gray
        }
        
        else if entry > 3.0 || entry < 7.0 {
            
            return NSUIColor.green
        }
        else {
            return NSUIColor.gray
        }
        
        
    }
    
    
}
