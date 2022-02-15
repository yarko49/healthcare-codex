import UIKit

class SplashViewController: UIViewController {
	let imageView: UIImageView = {
		let view = UIImageView(image: UIImage(named: "Logo"))
		view.contentMode = .center
		return view
	}()

	override var prefersStatusBarHidden: Bool {
		false
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		imageView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(imageView)
		NSLayoutConstraint.activate([imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0.0),
		                             imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0.0)])
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "SplashView"])
	}
}
