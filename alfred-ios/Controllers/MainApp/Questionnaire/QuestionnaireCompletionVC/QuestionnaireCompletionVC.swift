//
//  QuestionnaireCompletionVC.swift
//  alfred-ios
//

import Foundation
import UIKit

class QuestionnaireCompletionVC: BaseVC {
    
    // MARK: - Coordinator Actions
    var closeAction: (()->())?
    
    // MARK: - Properties
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var completionIV: UIImageView!
    @IBOutlet weak var thankYouLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var doneBtn: RoundedButton!
    
    // MARK: - Setup

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func setupView() {
        super.setupView()
        
    }
    
    override func localize() {
        super.localize()
        
        thankYouLbl.attributedText = Str.thankYou.with(style: .bold24, andColor: .black)
        descriptionLbl.attributedText = Str.surveySubmit.with(style: .regular16, andColor: .black)
        doneBtn.setTitle(Str.done, for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func populateData() {
        super.populateData()
    }
    
    @IBAction func dobeBtnTapped(_ sender: Any) {
        closeAction?()
    }
    
}




