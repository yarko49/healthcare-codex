import UIKit

class RegisterVC: BaseVC {
    
    // MARK: - Coordinator Actions
    var registerAction: ((String, String, String)->())?
    var loginAction: (()->())?
    
    // MARK: - Outlets
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    
    // MARK: - ViewController Setup
    override func setupView() {
        super.setupView()
    }
    
    override func setupLayout() {
        super.setupLayout()
    }
    
    override func bindActions() {
        super.bindActions()
        registerBtn.addTarget(self, action: #selector(registerTapped(_:)), for: .touchUpInside)
        loginBtn.addTarget(self, action: #selector(loginTapped(_:)), for: .touchUpInside)
    }
    
    override func localize() {
        super.localize()
        emailField.placeholder = Str.email
        passwordField.placeholder = Str.password
        confirmPasswordField.placeholder = Str.confirmPassword
        registerBtn.setTitle(Str.register, for: .normal)
        loginBtn.setTitle(Str.loginCTA, for: .normal)
    }
    

    override func populateData() {
        super.populateData()
    }
    
    // MARK: - Actions
    @objc private func registerTapped(_ sender: UIButton) {
        guard let email = emailField.text, let password = passwordField.text, let confirmPassword = confirmPasswordField.text else { return } // AND ANY VALIDATION
        registerAction?(email, password, confirmPassword)
    }
    
    @objc private func loginTapped(_ sender: UIButton) {
        loginAction?()
    }

}
