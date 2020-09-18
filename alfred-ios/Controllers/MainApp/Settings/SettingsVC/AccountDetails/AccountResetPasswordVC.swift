//
//  AccountResetPasswordVC.swift
//  alfred-ios
//

import Foundation
import UIKit

class AccountResetPasswordVC: BaseVC {
    
    //MARK: Coordinator Actions
    var backBtnAction: (()->())?
    var sendEmailAction: (()->())?
    
    // MARK: - Properties
    
    @IBOutlet weak var resetPasswordView: UIView!
    @IBOutlet weak var textfieldSV: UIStackView!
    @IBOutlet weak var sendBtn: RoundedButton!
    @IBOutlet weak var resetPasswordDescLbl: UILabel!
    @IBOutlet weak var completionLbl: UILabel!
    
    // MARK: - IBOutlets
    
    
    // MARK: - Setup

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backBtn = UIBarButtonItem(image: UIImage(named: "back")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(backBtnTapped))
        backBtn.tintColor = .black
        
        self.navigationItem.leftBarButtonItem = backBtn
    }
    
    override func setupView() {
        super.setupView()
        
        title = Str.resetPassword
        
        textfieldSV.addArrangedSubview(TextfieldView(labelTitle: Str.emailAddress, tfText: "", textIsPassword: false))
        completionLbl.isHidden = true
        sendBtn.cornerRadius = 29
        sendBtn.roundedBorderColor = UIColor.grey.cgColor
        sendBtn.roundedBackgroundColor = UIColor.white.cgColor

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func localize() {
        super.localize()
        
        resetPasswordDescLbl.attributedText = Str.resetPasswordDesc.with(style: .regular17, andColor: .lightGrey, andLetterSpacing: -0.408)
        sendBtn.setAttributedTitle(Str.send.uppercased().with(style: .regular17, andColor: .grey, andLetterSpacing: 3), for: .normal)
        completionLbl.attributedText = Str.resetPasswordResponse.with(style: .regular17, andColor: .lightGrey, andLetterSpacing: -0.408)
    }
    
    override func populateData() {
        super.populateData()
    }
    
    func showCompletionMessage() {
        completionLbl.isHidden = false
        resetPasswordView.isHidden = true
    }
    
    //MARK: - Actions
    
    @objc func backBtnTapped() {
        backBtnAction?()
    }
    
    @IBAction func passwordResetTapped(_ sender: Any) {
        sendEmailAction?()
    }
    
}

