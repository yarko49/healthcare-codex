//
//  EmailSaveVC.swift
//  alfred-ios

import UIKit
import FirebaseAuth
import Foundation

class ResetVC: BaseVC {
    
    
    //-MARK: Coordinator Actions
    
    var backBtnAction : (()->())?
    var nextAction: (()->())?
    
    //-MARK:IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var resetLbl: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    override func setupView() {
        super.setupView()
        navigationController?.navigationBar.isHidden = false
        let navBar = navigationController?.navigationBar
        navBar?.setBackgroundImage(UIImage(), for: .default)
        navBar?.shadowImage = UIImage()
        navBar?.isHidden = false
        navBar?.isTranslucent = false
        navBar?.layoutIfNeeded()
        title = "Reset Password"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backBtnTapped))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        saveBtn.addTarget(self, action: #selector(saveBtnTapped), for: .touchUpInside)
        setup()
    }
    
    func setup(){
        stackView.addArrangedSubview(TextfieldView(labelTitle: Str.email, tfText: "", textIsPassword: false))
        let save = UILabel()
        save.attributedText = Str.save.with(style: .regular17, andColor: UIColor.grey, andLetterSpacing: 3)
        saveBtn.setAttributedTitle(save.attributedText, for: .normal)
        saveBtn.layer.cornerRadius = 28.5
        saveBtn.backgroundColor = UIColor.white
        saveBtn.layer.borderWidth = 2.0
        saveBtn.layer.borderColor = UIColor.grey.cgColor
        resetLbl.attributedText = Str.resetMessage.with(style: .regular17, andColor: .lightGray, andLetterSpacing: -0.408)
        resetLbl.numberOfLines = 0
    }
    
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        nextAction?()
    }
    
    @objc func backBtnTapped(){
        backBtnAction?()
    }
}
