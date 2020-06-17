import UIKit

class HomeNC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBar = self.navigationBar 
        navBar.isTranslucent = false
        navBar.barTintColor = UIColor.veryLightGrey
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.layoutIfNeeded()
        
        navBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 25), NSAttributedString.Key.foregroundColor: UIColor.grey ?? UIColor.black]
    }
}
