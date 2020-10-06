//
//  TroubleshootingVC.swift
//  alfred-ios
//

import Foundation
import UIKit

class TroubleshootingVC: BaseVC {
    
    // MARK: - Coordinator Actions
    
    
    // MARK: - Properties
    
    var previewTitle: String = ""
    var titleText: String = ""
    var text: String = ""
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var textLbl: UILabel!
    @IBOutlet weak var actionBtn: UIButton!
    
    // MARK: - Setup
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func setupView() {
        super.setupView()
        
        self.title = previewTitle
        titleLbl.attributedText = titleText.with(style: .regular28, andColor: .black, andLetterSpacing: -0.41)
        textLbl.attributedText = titleText.with(style: .regular20, andColor: .black, andLetterSpacing: -0.41)
        actionBtn.setAttributedTitle(Str.getMoreInformation.with(style: .regular20, andColor: .cursorOrange, andLetterSpacing: -0.41), for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func populateData() {
        super.populateData()
    }
    
    @IBAction func actionBtnTapped(_ sender: Any) {
        //TODO: Action should be implemented.
    }
    
}




