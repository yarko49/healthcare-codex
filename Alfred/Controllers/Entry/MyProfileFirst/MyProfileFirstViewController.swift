import Firebase
import FirebaseAuth
import UIKit

class MyProfileFirstViewController: BaseViewController, UITextViewDelegate, UIGestureRecognizerDelegate {
	var backBtnAction: Coordinator.ActionHandler?
	var sendDataAction: ((String, String, [String]) -> Void)?
	var alertAction: ((_ tv: TextfieldView?) -> Void)?
	var alert: Coordinator.ActionHandler?

	@IBOutlet var sexStackView: UIStackView!
	@IBOutlet var sexLabel: UILabel!
	@IBOutlet var maleButton: UIButton!
	@IBOutlet var femaleButton: UIButton!
	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var lastNameTextfieldView: TextfieldView!
	@IBOutlet var firstNameTextfieldView: TextfieldView!
	@IBOutlet var nextButton: BottomButton!
	@IBOutlet var bottomView: UIView!

	var gender: Gender?
	var comingFrom: ComingFrom = .signUp
	var firstText: String = ""
	var lastText: String = ""

	private var selectedGender: Gender? {
		didSet {
			if selectedGender == .female {
				setupSexButton(maleTxtColor: .activityBackground, maleBackground: .white, femaleTextColor: .white, femaleBackground: .activityBackground)
			} else if selectedGender == .male {
				setupSexButton(maleTxtColor: .white, maleBackground: .activityBackground, femaleTextColor: .activityBackground, femaleBackground: .white)
			} else {
				setupSexButton(maleTxtColor: .activityBackground, maleBackground: .white, femaleTextColor: .activityBackground, femaleBackground: .white)
			}
		}
	}

	override func setupView() {
		super.setupView()
		scrollView.isScrollEnabled = false

		title = Str.profile

		// TODO: "Back" appears slightly before coming to this screen for some reason, we probably have to set the navigation controller before coming to this screen.
		if comingFrom == .signIn {
			navigationItem.setHidesBackButton(true, animated: true)
		} else {
			navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backBtnTapped))
			navigationItem.leftBarButtonItem?.tintColor = UIColor.black
		}

		firstNameTextfieldView.setupValues(labelTitle: Str.firstName, text: firstText, textIsPassword: false)
		lastNameTextfieldView.setupValues(labelTitle: Str.lastName, text: lastText, textIsPassword: false)

		nextButton.setAttributedTitle(Str.next.uppercased().with(style: .regular17, andColor: .white, andLetterSpacing: 5), for: .normal)
		nextButton.refreshCorners(value: 0)
		nextButton.setupButton()
		bottomView.backgroundColor = UIColor.next
		nextButton.backgroundColor = UIColor.next

		view.isUserInteractionEnabled = true
		view.layoutIfNeeded()
		setButtons()
	}

	func setButtons() {
		sexLabel.attributedText = Str.sex.with(style: .regular20, andColor: .grey, andLetterSpacing: -0.408)
		maleButton.layer.cornerRadius = 14.0
		femaleButton.layer.cornerRadius = 14.0
		maleButton.layer.borderWidth = 1
		femaleButton.layer.borderWidth = 1
		maleButton.layer.borderColor = UIColor.activityBackground.cgColor
		femaleButton.layer.borderColor = UIColor.activityBackground.cgColor
		if let gender = gender {
			selectedGender = gender
		} else {
			selectedGender = nil
		}
	}

	func setupSexButton(maleTxtColor: UIColor, maleBackground: UIColor, femaleTextColor: UIColor, femaleBackground: UIColor) {
		maleButton.backgroundColor = maleBackground
		let maleAttributedText = Str.male.with(style: .regular13, andColor: maleTxtColor, andLetterSpacing: -0.41)
		maleButton.setAttributedTitle(maleAttributedText, for: .normal)
		femaleButton.backgroundColor = femaleBackground
		let femaleAttributedText = Str.female.with(style: .regular13, andColor: femaleTextColor, andLetterSpacing: -0.41)
		femaleButton.setAttributedTitle(femaleAttributedText, for: .normal)
	}

	@IBAction func selectedOption(_ sender: UIButton) {
		if sender == maleButton {
			selectedGender = .male
		} else if sender == femaleButton {
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
		let firstName = firstNameTextfieldView.textfield.text ?? ""
		let lastName = lastNameTextfieldView.textfield.text ?? ""

		if !firstName.isValidText() || firstName.isEmpty {
			alertAction?(firstNameTextfieldView)
			return
		}
		if !lastName.isValidText() || lastName.isEmpty {
			alertAction?(lastNameTextfieldView)
		}

		guard let selectedGender = self.selectedGender else {
			alertAction?(nil)
			return
		}

		let givenNames = firstName.components(separatedBy: " ")

		sendDataAction?(selectedGender.rawValue, lastName, givenNames)
	}
}
