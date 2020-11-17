import UIKit

class BaseVC: UIViewController {
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
		print("\(String(describing: type(of: self))) deinitialized")
	}
}
