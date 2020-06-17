//
//  QuestionaireVC.swift
//  alfred-ios
//

import Foundation
import UIKit

import UIKit

class QuestionaireVC: BaseVC {
    
    // MARK: - Coordinator Actions
    var closeAction: (()->())?
    var startQuestionaireAction: (()->())?
    
    // MARK: - Properties
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var startQuestionaireBtn: RoundedButton!
    
    
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
    
    @IBAction func startQuestionaire(_ sender: Any) {
        startQuestionaireAction?()
    }
    
}

//extension QuestionaireVC {
//
//    func addBottomSheetView() {
//        let bottomSheetVC = CustomChartVC()
//        self.addChild(bottomSheetVC)
//        self.view.addSubview(bottomSheetVC.view)
//        bottomSheetVC.didMove(toParent: self)
//
//        let height = view.frame.height
//        let width  = view.frame.width
//        bottomSheetVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
//    }
//
//}




