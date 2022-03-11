import UIKit

class SplashViewController: UIViewController {
	private let imageView: UIImageView = {
		let view = UIImageView(image: UIImage(named: "img-splash"))
		view.contentMode = .scaleAspectFit
		return view
	}()

	private let titleImageView: UIImageView = {
		let view = UIImageView(image: UIImage(named: "img-splash-title"))
		view.contentMode = .scaleAspectFit
		return view
	}()

	override var prefersStatusBarHidden: Bool {
		false
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		imageView.translatesAutoresizingMaskIntoConstraints = false
		titleImageView.translatesAutoresizingMaskIntoConstraints = false
		[imageView, titleImageView].forEach { view.addSubview($0) }
		NSLayoutConstraint.activate([imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 20.0),
		                             imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0)])
		NSLayoutConstraint.activate([titleImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0.0),
		                             titleImageView.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: 0.0)])
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "SplashView"])
	}
}
