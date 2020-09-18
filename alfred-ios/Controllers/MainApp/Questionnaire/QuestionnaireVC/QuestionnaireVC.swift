//
//  QuestionnaireVC.swift
//  alfred-ios
//

import Foundation
import UIKit

import UIKit

class QuestionnaireVC: BaseVC {
    
    // MARK: - Coordinator Actions
    var closeAction: (()->())?
    var showQuestionnaireAction: (()->())?
    
    // MARK: - Properties
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var startQuestionnaireBtn: RoundedButton!
    
    // MARK: - Setup

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func setupView() {
        super.setupView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //self.addBottomSheetView()
    }
    
    override func populateData() {
        super.populateData()
    }
    
    @IBAction func close(_ sender: Any) {
        closeAction?()
    }
    
    @IBAction func showQuestionnaire(_ sender: Any) {
        showQuestionnaireAction?()
    }
    
}




