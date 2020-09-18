
//
//  SignupGenderVC.swift
//  alfred-ios


import UIKit
import Firebase
import FirebaseAuth


class MyProfileFirstVC : BaseVC , UITextViewDelegate, UIGestureRecognizerDelegate {
    
    var backBtnAction : (()->())?
    var nextBtnAction : (()->())?
    
    @IBOutlet weak var sexSV: UIStackView!
    @IBOutlet weak var genderIDSV: UIStackView!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var sexLbl: UILabel!
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var transBtn: UIButton!
    @IBOutlet weak var cisBtn: UIButton!
    @IBOutlet weak var nextBtn: BottomButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lastNameTF: TextfieldView!
    @IBOutlet weak var firstNameTF: TextfieldView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func setupView() {
        super.setupView()
        scrollView.isScrollEnabled = false
        navigationController?.navigationBar.isHidden = false
        let navBar = navigationController?.navigationBar
        navBar?.setBackgroundImage(UIImage(), for: .default)
        navBar?.shadowImage = UIImage()
        navBar?.isHidden = false
        navBar?.isTranslucent = false
        title = Str.profile
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backBtnTapped))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        firstNameTF.setupValues(labelTitle: Str.firstName, text: "", textIsPassword: false)
        lastNameTF.setupValues(labelTitle: Str.lastName, text: "", textIsPassword: false)
        bottomView.backgroundColor = UIColor.grey
        nextBtn.backgroundColor = UIColor.next
        nextBtn.setAttributedTitle(Str.next.uppercased().with(style: .regular17, andColor: .white, andLetterSpacing: 5), for: .normal)
        nextBtn.refreshCorners(value: 0)
        nextBtn.setupButton()
        self.view.isUserInteractionEnabled = true
        self.view.layoutIfNeeded()
        bottomConstraint.constant = UIWindow.keyWindow()?.safeAreaInsets.bottom ?? 0
        setUpView()
    }
    
    func setUpView(){
        genderLbl.attributedText = Str.gender.with(style: .regular20, andColor: .grey, andLetterSpacing: -0.408)
        sexLbl.attributedText = Str.sex.with(style: .regular20, andColor: .grey, andLetterSpacing: -0.408)
        maleBtn.layer.cornerRadius = 14.0
        femaleBtn.layer.cornerRadius = 14.0
        transBtn.layer.cornerRadius = 14.0
        cisBtn.layer.cornerRadius = 14.0
        maleBtn.layer.borderWidth = 1
        femaleBtn.layer.borderWidth = 1
        transBtn.layer.borderWidth = 1
        cisBtn.layer.borderWidth = 1
        maleBtn.layer.borderColor = UIColor.activityBG.cgColor
        femaleBtn.layer.borderColor = UIColor.activityBG.cgColor
        transBtn.layer.borderColor = UIColor.activityBG.cgColor
        cisBtn.layer.borderColor = UIColor.activityBG.cgColor
        
        setupSexBtn(maleTxtColor : UIColor.white , maleBG : UIColor.activityBG, femaleTxtColor : UIColor.activityBG, femaleBG : UIColor.white)
        setUpGenderBtn(transTxtColor : UIColor.white , transBG : UIColor.activityBG, cisTxtColor : UIColor.activityBG, cisBG : UIColor.white)
    }
    
    
    func setupSexBtn(maleTxtColor : UIColor , maleBG : UIColor, femaleTxtColor : UIColor, femaleBG : UIColor){
        maleBtn.backgroundColor = maleBG
        let maleAttributedText = Str.male.with(style: .regular13, andColor: maleTxtColor
            , andLetterSpacing: -0.41)
        maleBtn.setAttributedTitle(maleAttributedText, for: .normal)
        femaleBtn.backgroundColor = femaleBG
        let femaleAttributedText = Str.female.with(style: .regular13, andColor: femaleTxtColor, andLetterSpacing: -0.41)
        femaleBtn.setAttributedTitle(femaleAttributedText, for: .normal)
    }
    
    func setUpGenderBtn(transTxtColor : UIColor , transBG : UIColor, cisTxtColor : UIColor, cisBG : UIColor){
        transBtn.backgroundColor = transBG
        let transAttributedText = Str.trans.with(style: .regular13, andColor: transTxtColor, andLetterSpacing: -0.41)
        transBtn.setAttributedTitle(transAttributedText, for: .normal)
        cisBtn.backgroundColor = cisBG
        let cisAttributedText = Str.cis.uppercased().with(style: .regular13, andColor: cisTxtColor, andLetterSpacing: -0.41)
        cisBtn.setAttributedTitle(cisAttributedText, for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func selectedOption(_ sender : UIButton) {
        if sender == maleBtn {
            setupSexBtn(maleTxtColor : .white , maleBG : .activityBG, femaleTxtColor : .activityBG , femaleBG : .white)
        } else if sender == femaleBtn {
            setupSexBtn(maleTxtColor : .activityBG , maleBG : .white, femaleTxtColor : .white , femaleBG : .activityBG)
        } else if sender == transBtn {
            setUpGenderBtn(transTxtColor: .white, transBG: .activityBG, cisTxtColor: .activityBG, cisBG: .white)
        } else if sender == cisBtn {
            setUpGenderBtn(transTxtColor: .activityBG, transBG: .white, cisTxtColor: .white, cisBG: .activityBG)
        }
    }
    
    @objc func backBtnTapped() {
        backBtnAction?()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        nextBtnAction?()
    }
}
