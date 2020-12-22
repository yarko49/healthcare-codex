import JGProgressHUD
import os.log
import UIKit

class BaseViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupView()
		bindActions()
		setupLayout()
		localize()
		populateData()
	}

	let hud = AlertHelper.progressHUD

	func setupView() {}
	func bindActions() {}
	func setupLayout() {}
	func localize() {}
	func populateData() {}

	deinit {
		os_log(.info, log: .alfred, "%@ deinitialized", String(describing: type(of: self)))
	}
}
