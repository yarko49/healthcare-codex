//
//  EmailSignInVC.swift
//  alfred-ios

import UIKit
import FirebaseAuth
import Foundation

class EmailSignInVC: BaseVC {
    
    //-MARK: Coordinator Actions
    
    var backBtnAction : (()->())?
    var resetPasswordAction : (()->())?
    var signInWithEP: ((_ email : String, _ password : String)->())?
    
    //-MARK: IBOutlets
    
    @IBOutlet var screen: UIView!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var emailView: TextfieldView!
    @IBOutlet weak var passwordView: TextfieldView!
    
    
    override func setupView() {
        super.setupView()
        navigationController?.navigationBar.isHidden = false
        let navBar = navigationController?.navigationBar
        navBar?.setBackgroundImage(UIImage(), for: .default)
        navBar?.shadowImage = UIImage()
        navBar?.isHidden = false
        navBar?.isTranslucent = false
        title = Str.welcomeBack
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backBtnTapped))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        emailView.setupValues(labelTitle: Str.email, text: "", textIsPassword: false)
        passwordView.setupValues(labelTitle: Str.password, text: "", textIsPassword: true)
        forgotPasswordBtn.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        setup()
        self.view.layoutIfNeeded()
    }
    
    func setup(){
        let forgotPassword = UILabel()
        forgotPassword.attributedText = Str.forgotPassword.with(style: .regular17, andColor: UIColor.lightGrey , andLetterSpacing: -0.408)
        forgotPasswordBtn.setAttributedTitle(forgotPassword.attributedText, for: .normal)
        let signIn = UILabel()
        signIn.attributedText = Str.signin.with(style: .regular17, andColor: UIColor.white , andLetterSpacing: 3)
        signInBtn.setAttributedTitle(signIn.attributedText, for: .normal)
        signInBtn.layer.cornerRadius = 5
        signInBtn.backgroundColor = UIColor.grey
    }
    
    @IBAction func signInBtnTapped(_ sender: Any) {
        
        guard let email = emailView.tfText, !email.isEmpty else {
            showAlert(title : Str.invalidEmail, message: Str.enterEmail, type : 0)
            return
        }
        
        guard let password = passwordView.tfText, !password.isEmpty else {
            showAlert(title: Str.invalidPw, message: Str.enterPw, type : 1)
            return
        }
        
        signInWithEP?(email , password )
    }
    
    
    func showAlert(title : String, message : String, type : Int ){
        
        let alert = UIAlertController(title: title, message: message , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Str.ok , style: .default, handler: {[weak self] _ in
            self?.responder(idx : type)
        }))
        self.present(alert,animated: true)
    }
    
    func responder(idx : Int){
        if idx == 0 {
            self.emailView.focus()
        } else {
            self.passwordView.focus()
        }
    }
    
    @objc func forgotPasswordTapped(){
        resetPasswordAction?()
    }
    
    @objc func backBtnTapped(){
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.layoutIfNeeded()
        backBtnAction?()
    }
}
