//
//  AccountDetailsVC.swift
//  alfred-ios
//

import Foundation
import UIKit

class AccountDetailsVC: BaseVC {
    
    //MARK: Coordinator Actions
    var backBtnAction: (()->())?
    var resetPasswordAction: (()->())?
    
    // MARK: - Properties
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var textfieldSV: UIStackView!
    @IBOutlet weak var passwordLbl: UILabel!
    @IBOutlet weak var passwordTF: UITextField!
    
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
        
        title = Str.accountDetails
        
        //TODO: Add tfText when we get it.
        
        textfieldSV.addArrangedSubview(TextfieldView(labelTitle: Str.firstName, tfText: "", textIsPassword: false))
        textfieldSV.addArrangedSubview(TextfieldView(labelTitle: Str.lastName, tfText: "", textIsPassword: false))
        textfieldSV.addArrangedSubview(TextfieldView(labelTitle: Str.emailAddress, tfText: "", textIsPassword: false))
        passwordTF.isUserInteractionEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func localize() {
        super.localize()
    
        passwordLbl.attributedText = Str.password.with(style: .regular13, andColor: .lightGrey, andLetterSpacing: -0.078)
        passwordTF.attributedText = "".with(style: .regular17, andColor: .black, andLetterSpacing: 0.38)
    }
    
    override func populateData() {
        super.populateData()
    }
    
    //MARK: - Actions
    
    @objc func backBtnTapped() {
        backBtnAction?()
    }
    
    @IBAction func passwordResetTapped(_ sender: Any) {
        resetPasswordAction?()
    }
    
}

