
import UIKit
import Foundation


enum ComingFromScreen {
    case myProfile
    case myDevices
    case activate
}

class AppleHealthVC: BaseVC {
    
    var backBtnAction : (()->())?
    var nextBtnAction: (()->())?
    var notNowAction: (()->())?
    var activateAction: (()->())?
    
    var comingFrom: ComingFromScreen?
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var nextBtn: BottomButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var leftBtn: UIButton!
    
    override func setupView() {
        super.setupView()
        setupTexts()
        setupNavBar()
        nextBtn.addTarget(self, action: #selector(nextBtnTapped), for: .touchUpInside)
    }
    
    private func setupNavBar() {
        if comingFrom == .myProfile {
            navigationController?.navigationBar.isHidden = false
            let navBar = navigationController?.navigationBar
            navBar?.setBackgroundImage(UIImage(), for: .default)
            navBar?.shadowImage = UIImage()
            navBar?.isHidden = false
            navBar?.isTranslucent = true
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backBtnTapped))
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
            self.view.isUserInteractionEnabled = true
        } else {
            navigationController?.navigationBar.isHidden = true
        }
    }
    
    private func setupTexts() {
        switch comingFrom {
        case .myProfile:
            title = Str.myDevices
            reusableView(title: Str.appleHealthSelect, descr: Str.appleSelectMessage)
            
        case .myDevices:
            reusableView(title: Str.appleHealthImport, descr:Str.appleImportMessage)
            
        case .activate:
            reusableView(title: Str.synced, descr: "")
            
        default:
            return
        }
        switchScreen()
    }
    
    func reusableView(title: String, descr: String) {
        let appleHealthView = AppleHealthView(title: title , descr: descr)
        stackView.addArrangedSubview(appleHealthView)
        view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
    }
    
    func switchScreen() {
        leftBtnView()
        rightBtnView()
        nextBtnView()
    }
    
    func leftBtnView() {
        let attrText = Str.notNow.with(style: .regular20, andColor: .black, andLetterSpacing: 0.38)
        leftBtn.setAttributedTitle(attrText, for: .normal)
        leftBtn.isHidden = comingFrom != .myDevices
        leftBtn.layer.cornerRadius = 20.0
        leftBtn.layer.borderWidth = 1
        leftBtn.layer.borderColor = UIColor.grey.cgColor
    }
    
    func rightBtnView() {
        let attrText = Str.activate.with(style: .regular20, andColor: .white, andLetterSpacing: 0.38)
        rightBtn.setAttributedTitle(attrText, for: .normal)
        rightBtn.isHidden = comingFrom != .myDevices
        rightBtn.layer.cornerRadius = 20.0
        rightBtn.backgroundColor = .grey
    }
    
    func nextBtnView() {
        let text = comingFrom != .activate ? Str.next.uppercased() : Str.done.uppercased()
        bottomView.isHidden = comingFrom == .myDevices
        nextBtn.isHidden = comingFrom == .myDevices
        nextBtn.backgroundColor = UIColor.next
        nextBtn.setAttributedTitle(text.with(style: .regular17, andColor: .white, andLetterSpacing: 5), for: .normal)
        nextBtn.refreshCorners(value: 0)
        nextBtn.setupButton()
        nextBtn.backgroundColor = comingFrom != .activate ? .next : .grey
        bottomView.backgroundColor = nextBtn.backgroundColor
    }
    
    
    @IBAction func notNowTapped(_ sender: Any) {
        notNowAction?()
    }
    
    @IBAction func activateTapped(_ sender: Any) {
        activateAction?()
    }
    
    @objc func nextBtnTapped(){
        nextBtnAction?()
    }
    
    @objc func backBtnTapped(){
        backBtnAction?()
    }
}

