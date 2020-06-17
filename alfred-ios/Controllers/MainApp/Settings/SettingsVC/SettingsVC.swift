import UIKit

class SettingsVC: BaseVC {
    
    var closeAction: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let closeBtn = UIBarButtonItem(title: Str.close, style: .plain, target: self, action: #selector(closeTapped(_:)))
        navigationItem.leftBarButtonItem = closeBtn
    }

    @objc private func closeTapped(_ sender: UIBarButtonItem) {
        closeAction?()
    }
}
