import UIKit

class LoginVC: BaseVC {
    // MARK - Coordinator Actions
    var loginAction: ((String, String)->())?
    var registerAction: (()->())?
    
    // MARK: - Outlets
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    // MARK: - ViewController Setup
    override func setupView() {
        super.setupView()
    }

    override func setupLayout() {
        super.setupLayout()
    }

    override func bindActions() {
        super.bindActions()
    }
    
    override func localize() {
        super.localize()
        emailField.placeholder = Str.email
        passwordField.placeholder = Str.password
        loginBtn.setTitle(Str.login, for: .normal)
        registerBtn.setTitle(Str.registerCTA, for: .normal)
    }
    
    override func populateData() {
        super.populateData()
    }
    
    // MARK: - Actions
    @IBAction private func loginTapped(_ sender: UIButton) {
        guard let email = emailField.text, let password = passwordField.text else { return }
        loginAction?(email, password)
    }
    
    @IBAction private func registerTapped(_ sender: UIButton) {
        registerAction?()
    }
}
