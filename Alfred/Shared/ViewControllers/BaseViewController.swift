import JGProgressHUD
import UIKit

protocol ViewControllerInitializable {
	var hud: JGProgressHUD { get }
	func setupView()
	func bindActions()
	func setupLayout()
	func localize()
	func populateData()
}

class BaseViewController: UIViewController, ViewControllerInitializable {
	let hud = AlertHelper.progressHUD

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupView()
		bindActions()
		setupLayout()
		localize()
		populateData()
	}

	func setupView() {}
	func bindActions() {}
	func setupLayout() {}
	func localize() {}
	func populateData() {}

	deinit {
		ALog.info("\(String(describing: type(of: self))) deinitialized")
	}
}
