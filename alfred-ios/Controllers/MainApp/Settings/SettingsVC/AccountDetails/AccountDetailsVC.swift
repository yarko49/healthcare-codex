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
    
    var firstNameTV = TextfieldView()
    var lastNameTV = TextfieldView()
    var emailTV = TextfieldView()

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
    
        let firstName = DataContext.shared.getDisplayFirstName()
        let lastName = DataContext.shared.getDisplayLastName()
        guard let email = DataContext.shared.userModel?.email else { return }
        
        firstNameTV.setupValues(labelTitle: Str.firstName, text: firstName, textIsPassword: false)
        lastNameTV.setupValues(labelTitle: Str.lastName, text: lastName, textIsPassword: false)
        emailTV.setupValues(labelTitle: Str.email, text: email, textIsPassword: false)
    
        textfieldSV.addArrangedSubview(firstNameTV)
        textfieldSV.addArrangedSubview(lastNameTV)
        textfieldSV.addArrangedSubview(emailTV)
        passwordTF.isUserInteractionEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func localize() {
        super.localize()
    
        passwordLbl.attributedText = Str.password.with(style: .regular13, andColor: .lightGrey, andLetterSpacing: -0.078)
        passwordTF.isSecureTextEntry = true
        passwordTF.attributedText = "1234567890".with(style: .regular17, andColor: .black, andLetterSpacing: 0.38)
       
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

