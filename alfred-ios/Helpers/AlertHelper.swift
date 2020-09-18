import UIKit
import SVProgressHUD

class AlertHelper {
    
    struct AlertAction {
        let title: String
        let style: UIAlertAction.Style
        let action: (() -> ())?
        
        init(withTitle title: String, style: UIAlertAction.Style = .default, andAction action: (() -> ())?  = nil){
            self.title = title
            self.style = style
            self.action = action
        }
    }
    
   
    static func showLoader() {
       SVProgressHUD.show()
    }
    
    static func hideLoader() {
       SVProgressHUD.dismiss()
    }
    
    static func showSendLoader() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setBackgroundColor(.clear)
        SVProgressHUD.show()
    }
    
    static func showAlert(title: String?, detailText: String?, actions: [AlertAction], style: UIAlertController.Style = .alert, fillProportionally: Bool = false, from viewController: UIViewController? = UIApplication.shared.keyWindow?.visibleViewController()) {
        hideLoader()
        let alertVC = UIAlertController(title: title, message: detailText, preferredStyle: style)
        actions.forEach { (alertAction) in
            let action = UIAlertAction(title: alertAction.title, style: alertAction.style, handler: { (_) in
                alertAction.action?()
            })
            alertVC.addAction(action)
        }
        present(alertVC, from: viewController)
    }
    
    
    static func present(_ modalViewController: UIViewController?, from viewController: UIViewController? = UIApplication.shared.keyWindow?.visibleViewController()) {
        guard let modalViewController = modalViewController else { return }
        modalViewController.modalTransitionStyle = .crossDissolve
        modalViewController.modalPresentationStyle = .overFullScreen
        viewController?.present(modalViewController, animated: true, completion: nil)
    }
}
