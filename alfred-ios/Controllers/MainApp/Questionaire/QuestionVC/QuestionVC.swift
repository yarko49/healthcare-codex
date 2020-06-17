//
//  QuestionVC.swift
//  alfred-ios
//

import Foundation
import UIKit

import UIKit

class QuestionVC: BaseVC {
    
    // MARK: - Coordinator Actions
    var closeAction: (()->())?
    
    // MARK: - Properties
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var progressBar: UIProgressView!
    
    // MARK: - Setup

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func setupView() {
        super.setupView()
        
        self.setupProgressBar()
        
    }

    override func populateData() {
        super.populateData()
    }
    
    private func setupProgressBar() {
        progressBar.progressTintColor = .blue
        progressBar.trackTintColor = .gray
        progressBar.layer.cornerRadius = 5
        progressBar.clipsToBounds = true
        progressBar.layer.sublayers?[1].cornerRadius = 4
        progressBar.subviews[1].clipsToBounds = true
    }
    
    func changeProgress(step: Int = 3) {
           let progress = step != 6 ? Float(Double( step * 14) / 100.0) : 100.0
           progressBar.setProgress(progress, animated: true)
       }
    
}

