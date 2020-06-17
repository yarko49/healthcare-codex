//
//  BottomSheetNC.swift
//  alfred-ios
//

import Foundation

import UIKit

class BottomSheetNC: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarHidden(true, animated: false)
        modalPresentationStyle = .custom
    }
    
}
