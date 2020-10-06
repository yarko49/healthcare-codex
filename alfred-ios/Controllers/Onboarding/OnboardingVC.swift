//
//  OnboardingVC.swift
//  alfred-ios


import UIKit
import GoogleSignIn
import FirebaseAuth
import Firebase
import AuthenticationServices
import CryptoKit

class OnboardingVC: BaseVC , UIViewControllerTransitioningDelegate  {
    
    var signInWithAppleAction: (() -> ())?
    var signInWithEmailAction: (()->())?
    var signupAction : (()->())?
    
    // MARK: - Initializer
    @IBOutlet weak var googleSignInBtn: GoogleSignInButton!
    @IBOutlet weak var appleSignInBtn: AAPLSignInButton!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var signLbl: UILabel!
    @IBOutlet weak var signUpBottomBtn: BottomButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var swipe: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var alreadyHaveAccountLbl: UILabel!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackViewCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailSignInBtn: EmailSignInButton!
    
    override func setupView() {
        super.setupView()
        navigationController?.navigationBar.isHidden = true
        setupModalView()
        setupOnboarding()
        
        stackViewCenterXConstraint.isActive = false
        pageControl.currentPage = 0
        scrollView.delegate = self
        
        let views = [subView, shadowView]
        appleSignInBtn.addTarget(self, action: #selector(signInWithApple), for: .touchUpInside)
        cancelBtn.addTarget(self, action: #selector(hideModal), for: .touchUpInside)
        for view in views {
            if let view = view {
                let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(hideModal))
                downSwipe.direction = .down
                view.addGestureRecognizer(downSwipe)
            }
        }
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        self.contentView.isUserInteractionEnabled = true
        
        bottomConstraint.constant = -UIScreen.main.bounds.height
        self.shadowView.isHidden = true
        self.shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    override func localize() {
        super.localize()
        
        alreadyHaveAccountLbl.attributedText = Str.alreadyHaveAccount.with(style: .regular17, andColor: .lightGrey, andLetterSpacing: -0.32)
        signInBtn.setAttributedTitle(Str.login.with(style: .regular16, andColor: .orange, andLetterSpacing: -0.32), for: .normal)
        signUpBottomBtn.setAttributedTitle(Str.signup.uppercased().with(style: .semibold17, andColor: .white), for: .normal)
        signUpBottomBtn.refreshCorners(value: 5)
        signUpBottomBtn.setupButton()
    }
    
    func setupModalView(){
        self.subView.translatesAutoresizingMaskIntoConstraints = false
        self.subView.autoresizingMask = [ .flexibleTopMargin, .flexibleHeight]
        self.subView.layer.cornerRadius = 16.0
        self.subView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.subView.clipsToBounds = true
        let cancel = UILabel()
        cancel.attributedText = Str.cancel.with(style: .regular17, andColor: UIColor.veryLightGrey ?? UIColor.lightGrey , andLetterSpacing: -0.408)
        cancelBtn.setAttributedTitle(cancel.attributedText, for: .normal)
        cancelBtn.addTarget(self, action: #selector(hideModal), for: .touchUpInside)
        swipe.backgroundColor = UIColor.swipeColor
        swipe.layer.cornerRadius = 5.0
    }

    private func setupOnboarding() {
        let titles = [Str.slide1Title, Str.slide2Title, Str.slide3Title]
        let descriptions = [Str.slide1Desc, Str.slide2Desc, Str.slide3Desc]
        
        for index in 0..<titles.count {
            let view = OnboardingView(title: titles[index], descr: descriptions[index])
            
            stackView.addArrangedSubview(view)
            view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        }
    }
    
    @IBAction func googleSignBtnTapped(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
        self.view.layer.opacity = 1.0
        self.view.backgroundColor = UIColor.red.withAlphaComponent(0.5)
    }
    
    @objc func hideModal(){
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: [],
                       animations: {
                        self.subView.frame.origin.x = 0
                        self.subView.frame.origin.y = UIScreen.main.bounds.height
        })
        self.bottomConstraint.constant = -self.subView.frame.height
        self.shadowView.isHidden = true
    }
    
    
    
    @objc func showModal(type : Int){
        
        if type == 0 {
            setupModal(string : Str.signup, email : Str.signUpWithYourEmail, apple : Str.signUpWithApple, google : Str.signUpWithGoogle)
        } else {
            
            setupModal(string : Str.signInModal, email : Str.signInWithYourEmail, apple : Str.signInWithApple, google : Str.signInWithGoogle)
        }
        
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: [],
                       animations: {
                        self.subView.frame.origin.x = 0
                        self.subView.frame.origin.y = self.subView.frame.height
        })
        self.bottomConstraint.constant = 0
        self.shadowView.isHidden = false
        
    }
    
    func setupModal(string : String, email : String, apple : String, google : String){
        
        var attributedText = string.with(style: .semibold17, andColor: UIColor.black , andLetterSpacing: -0.408)
        signLbl.attributedText = attributedText
        attributedText = email.with(style: .regular20, andColor: UIColor.grey, andLetterSpacing: 0.38)
        emailSignInBtn.setAttributedTitle(attributedText, for: .normal)
        googleSignInBtn.setupValues(labelTitle: google)
        appleSignInBtn.setupValues(labelTitle: apple)
        
    }
    
    @objc func signInWithApple(){
        signInWithAppleAction?()
    }
    
    @IBAction func signUpBottomBtnTapped(_ sender: Any) {
        showModal(type : 0)
    }
    
    @IBAction func signInWIthEmail(_ sender: Any) {
        
        if emailSignInBtn.titleLabel?.text == Str.signInWithYourEmail{
            signInWithEmailAction?()
        }else if emailSignInBtn.titleLabel?.text == Str.signUpWithYourEmail{
            signupAction?()
        }
    }

    @IBAction func signInBtnTapped(_ sender: Any) {
        showModal(type : 1)
    }
    
    @IBAction func signup(_ sender: Any) {
    }
}

extension OnboardingVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        let page = Int(pageIndex)
        pageControl.currentPage = page
    }
}
