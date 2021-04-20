import Combine
import JGProgressHUD
import UIKit

protocol ViewControllerInitializable {
	func setupView()
	func bindActions()
	func setupLayout()
	func localize()
	func populateData()
}

class BaseViewController: UIViewController, ViewControllerInitializable {
	var cancellables: Set<AnyCancellable> = []

	let hud: JGProgressHUD = {
		let view = JGProgressHUD(style: .dark)
		view.vibrancyEnabled = true
		return view
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.back"), style: .plain, target: nil, action: nil)
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
