//
//  HealthKitAuthorizationVC.swift
//  alfred-ios
//

import Foundation
import UIKit

class HealthKitAuthorizationVC: BaseVC {
    // MARK - Coordinator Actions
    var authorizeAction: (()->())?
    
    // MARK: - Outlets

    @IBOutlet weak var authorizeHealthKitBtn: UIButton!
    
    // MARK: - ViewController Setup
    override func setupView() {
        super.setupView()
    }

    override func setupLayout() {
        super.setupLayout()
    }

    override func bindActions() {
        super.bindActions()
    }
    
    override func localize() {
        super.localize()
    }
    
    override func populateData() {
        super.populateData()
        
    }
    
    // MARK: - Actions
    
    @IBAction private func authorizeHealthKitTapped(_ sender: UIButton) {
        authorizeAction?()
    }
}
