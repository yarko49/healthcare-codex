import UIKit

class SettingsNC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBar = self.navigationBar
        navBar.isTranslucent = true
        navBar.barTintColor = UIColor.white
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.layoutIfNeeded()
        
        navBar.titleTextAttributes = [NSAttributedString.Key.font: Font.sfProSemibold.of(size: 17), NSAttributedString.Key.foregroundColor: UIColor.black]
    }
}
