import UIKit

class MasterCoordinator: Coordinator {
	private var window: UIWindow

	internal var childCoordinators: [CoordinatorKey: Coordinator]
	internal var navigationController: UINavigationController?

	public var rootViewController: UIViewController? {
		navigationController
	}

	init(in window: UIWindow) {
		self.childCoordinators = [:]
		self.window = window
		self.window.rootViewController = rootViewController
		self.window.makeKeyAndVisible()
	}

	public func start() {
		if !DataContext.shared.hasRunOnce {
			DataContext.shared.clearAll()
			DataContext.shared.hasRunOnce = true
		}
		showMockSplashScreen()
	}

	internal func showMockSplashScreen() {
		let mockSplashVC = MockSplashVC()
		window.rootViewController = mockSplashVC

		DataContext.shared.initialize { [weak self] _ in
			// HERE YOU CAN CONTROL THE FLOW ACCORDING TO THE RESULT OF THE init method
			self?.goToAuth()
		}
	}

	public func goToAuth() {
		removeChild(.mainAppCoordinator)
		DataContext.shared.clearAll()
		let authCoordinator = AuthCoordinator(withParent: self)
		addChild(coordinator: authCoordinator, with: .authCoordinator)
		window.rootViewController = authCoordinator.rootViewController
	}

	public func goToMainApp(showingLoader: Bool = true) {
		removeChild(.authCoordinator)
		let mainAppCoordinator = MainAppCoordinator(with: self)
		addChild(coordinator: mainAppCoordinator, with: .mainAppCoordinator)
		window.rootViewController = mainAppCoordinator.rootViewController
	}
}
