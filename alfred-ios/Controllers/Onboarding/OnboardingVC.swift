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
    @IBOutlet weak var signupBtn: UIButton!
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
        
        let signup = UILabel()
        signup.attributedText = Str.signup.with(style: .semibold17, andColor: UIColor.black , andLetterSpacing: -0.408)
        signupBtn.setAttributedTitle(signup.attributedText, for: .normal)
        let cancel = UILabel()
        cancel.attributedText = Str.cancel.with(style: .regular17, andColor: UIColor.veryLightGrey ?? UIColor.lightGrey , andLetterSpacing: -0.408)
        
        cancelBtn.setAttributedTitle(cancel.attributedText, for: .normal)
        cancelBtn.addTarget(self, action: #selector(hideModal), for: .touchUpInside)
        swipe.backgroundColor = UIColor.swipeColor
        swipe.layer.cornerRadius = 5.0
        let lbl = UILabel()
        lbl.attributedText = Str.signInWithYourEmail.with(style: .regular20, andColor: UIColor.grey, andLetterSpacing: 0.38)
        emailSignInBtn.setAttributedTitle(lbl.attributedText, for: .normal)
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
    
    @objc func showModal(){
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
    
    
    @objc func signInWithApple(){
        signInWithAppleAction?()
    }

    @IBAction func signUpBottomBtnTapped(_ sender: Any) {
        //TODO: Add the Sign up flow here
        signupAction?()
    }
    
    @IBAction func signInWIthEmail(_ sender: Any) {
        signInWithEmailAction?()
    }
    
    
    @IBAction func signInBtnTapped(_ sender: Any) {
        showModal()
    }
    
    @IBAction func signup(_ sender: Any) {
        signupAction?()
    }
}

extension OnboardingVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        let page = Int(pageIndex)
        pageControl.currentPage = page
    }
}
