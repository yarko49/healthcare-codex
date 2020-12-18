import Firebase
import FirebaseAuth
import UIKit

class MyProfileFirstVC: BaseViewController, UITextViewDelegate, UIGestureRecognizerDelegate {
	var backBtnAction: (() -> Void)?
	var sendDataAction: ((String, String, [String]) -> Void)?
	var alertAction: ((_ tv: TextfieldView?) -> Void)?
	var alert: (() -> Void)?

	@IBOutlet var sexSV: UIStackView!
	@IBOutlet var sexLbl: UILabel!
	@IBOutlet var maleBtn: UIButton!
	@IBOutlet var femaleBtn: UIButton!
	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var lastNameTF: TextfieldView!
	@IBOutlet var firstNameTF: TextfieldView!
	@IBOutlet var nextBtn: BottomButton!
	@IBOutlet var bottomView: UIView!

	var gender: Gender?
	var comingFrom: ComingFrom = .signUp
	var firstText: String = ""
	var lastText: String = ""

	private var selectedGender: Gender? {
		didSet {
			if selectedGender == .female {
				setupSexBtn(maleTxtColor: .activityBG, maleBG: .white, femaleTxtColor: .white, femaleBG: .activityBG)
			} else if selectedGender == .male {
				setupSexBtn(maleTxtColor: .white, maleBG: .activityBG, femaleTxtColor: .activityBG, femaleBG: .white)
			} else {
				setupSexBtn(maleTxtColor: .activityBG, maleBG: .white, femaleTxtColor: .activityBG, femaleBG: .white)
			}
		}
	}

	override func setupView() {
		super.setupView()
		scrollView.isScrollEnabled = false
		let navBar = navigationController?.navigationBar

		title = Str.profile

		// TODO: "Back" appears slightly before coming to this screen for some reason, we probably have to set the navigation controller before coming to this screen.
		if comingFrom == .signIn {
			navigationItem.setHidesBackButton(true, animated: true)
		} else {
			navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backBtnTapped))
			navigationItem.leftBarButtonItem?.tintColor = UIColor.black
		}
		navBar?.isHidden = false
		navBar?.setBackgroundImage(UIImage(), for: .default)
		navBar?.shadowImage = UIImage()
		navBar?.isHidden = false
		navBar?.isTranslucent = false

		firstNameTF.setupValues(labelTitle: Str.firstName, text: firstText, textIsPassword: false)
		lastNameTF.setupValues(labelTitle: Str.lastName, text: lastText, textIsPassword: false)

		nextBtn.setAttributedTitle(Str.next.uppercased().with(style: .regular17, andColor: .white, andLetterSpacing: 5), for: .normal)
		nextBtn.refreshCorners(value: 0)
		nextBtn.setupButton()
		bottomView.backgroundColor = UIColor.next
		nextBtn.backgroundColor = UIColor.next

		view.isUserInteractionEnabled = true
		view.layoutIfNeeded()
		setButtons()
	}

	func setButtons() {
		sexLbl.attributedText = Str.sex.with(style: .regular20, andColor: .grey, andLetterSpacing: -0.408)
		maleBtn.layer.cornerRadius = 14.0
		femaleBtn.layer.cornerRadius = 14.0
		maleBtn.layer.borderWidth = 1
		femaleBtn.layer.borderWidth = 1
		maleBtn.layer.borderColor = UIColor.activityBG.cgColor
		femaleBtn.layer.borderColor = UIColor.activityBG.cgColor
		if let gender = gender {
			selectedGender = gender
		} else {
			selectedGender = nil
		}
	}

	func setupSexBtn(maleTxtColor: UIColor, maleBG: UIColor, femaleTxtColor: UIColor, femaleBG: UIColor) {
		maleBtn.backgroundColor = maleBG
		let maleAttributedText = Str.male.with(style: .regular13, andColor: maleTxtColor,
		                                       andLetterSpacing: -0.41)
		maleBtn.setAttributedTitle(maleAttributedText, for: .normal)
		femaleBtn.backgroundColor = femaleBG
		let femaleAttributedText = Str.female.with(style: .regular13, andColor: femaleTxtColor, andLetterSpacing: -0.41)
		femaleBtn.setAttributedTitle(femaleAttributedText, for: .normal)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	@IBAction func selectedOption(_ sender: UIButton) {
		if sender == maleBtn {
			selectedGender = .male
		} else if sender == femaleBtn {
			selectedGender = .female
		}
	}

	@objc func backBtnTapped() {
		backBtnAction?()
	}

	@objc func dismissKeyboard() {
		view.endEditing(true)
	}

	@IBAction func nextBtnTapped(_ sender: Any) {
		let firstName = firstNameTF.textfield.text ?? ""
		let lastName = lastNameTF.textfield.text ?? ""

		if !firstName.isValidText() || firstName.isEmpty {
			alertAction?(firstNameTF)
			return
		}
		if !lastName.isValidText() || lastName.isEmpty {
			alertAction?(lastNameTF)
		}

		guard let selectedGender = self.selectedGender else {
			alertAction?(nil)
			return
		}

		let givenNames = firstName.components(separatedBy: " ")

		print(firstName, lastName, givenNames)
		sendDataAction?(selectedGender.rawValue, lastName, givenNames)
	}
}
