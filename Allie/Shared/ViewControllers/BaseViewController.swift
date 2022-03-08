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

	var heightConstraint: NSLayoutConstraint = .init()

	var isShowChatVC: Bool = false

	var hasTopNotch: Bool {
		if #available(iOS 11.0, *) {
			return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
		}
		return false
	}

	private(set) lazy var hud: JGProgressHUD = {
		let view = JGProgressHUD(style: .dark)
		view.vibrancyEnabled = true
		view.textLabel.text = NSLocalizedString("LOADING", comment: "Loading")
		view.detailTextLabel.text = NSLocalizedString("YOUR_CAREPLAN", comment: "Your Care Plan")
		return view
	}()

	var chatStackView: UIStackView = {
		let chatStackView = UIStackView()
		chatStackView.translatesAutoresizingMaskIntoConstraints = false
		chatStackView.distribution = .fill
		chatStackView.alignment = .fill
		chatStackView.axis = .vertical
		return chatStackView
	}()

	private var leadingHStack: UIStackView = {
		let leadingHStack = UIStackView()
		leadingHStack.translatesAutoresizingMaskIntoConstraints = false
		leadingHStack.axis = .horizontal
		leadingHStack.alignment = .center
		leadingHStack.distribution = .fill
		leadingHStack.spacing = 12.0
		return leadingHStack
	}()

	private var backButton: UIButton = {
		let backButton = UIButton()
		backButton.translatesAutoresizingMaskIntoConstraints = false
		backButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
		backButton.setImage(UIImage(systemName: "arrow.up"), for: .normal)
		backButton.layer.cornerRadius = 22.0
		backButton.setTitle("", for: .normal)
		backButton.tintColor = .white
		return backButton
	}()

	private var greetingLabel: UILabel = {
		let greetingLabel = UILabel()
		greetingLabel.translatesAutoresizingMaskIntoConstraints = false
		greetingLabel.textColor = .white
		greetingLabel.font = .systemFont(ofSize: 14.0, weight: .bold)
		greetingLabel.text = "Monitored By UCHealth"
		return greetingLabel
	}()

	private var onlineView: UIView = {
		let onlineView = UIView()
		onlineView.translatesAutoresizingMaskIntoConstraints = false
		onlineView.backgroundColor = .mainLightGreen
		onlineView.layer.cornerRadius = 5.0
		return onlineView
	}()

	private var onlineLabel: UILabel = {
		let onlineLabel = UILabel()
		onlineLabel.translatesAutoresizingMaskIntoConstraints = false
		onlineLabel.text = "ONLINE"
		onlineLabel.textColor = .mainLightGreen
		onlineLabel.font = .systemFont(ofSize: 14.0, weight: .bold)
		return onlineLabel
	}()

	private var chatImageView: UIImageView = {
		let chatImageView = UIImageView()
		chatImageView.translatesAutoresizingMaskIntoConstraints = false
		chatImageView.image = UIImage(systemName: "message.fill")
		chatImageView.tintColor = .white
		return chatImageView
	}()

	private var badgeCountView: BadgeView = {
		let badgeCountView = BadgeView()
		badgeCountView.translatesAutoresizingMaskIntoConstraints = false
		return badgeCountView
	}()

	private var badgeView: UIStackView = {
		let badgeView = UIStackView()
		badgeView.translatesAutoresizingMaskIntoConstraints = false
		badgeView.axis = .horizontal
		badgeView.alignment = .center
		badgeView.spacing = -12.0
		return badgeView
	}()

	private var navigationView: UIView!

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupView()
		bindActions()
		setupLayout()
		localize()
		populateData()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupNavigationView()

		NotificationCenter.default.addObserver(self, selector: #selector(observeChatNotification), name: .didReceiveChatNotification, object: nil)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationView.removeFromSuperview()
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
		ALog.trace("\(String(describing: type(of: self))) deinitialized")
	}

	func setupView() {}
	func bindActions() {}
	func setupLayout() {}
	func localize() {}
	func populateData() {}

	@objc func observeChatNotification() {
		badgeCountView.badgeCount = UserDefaults.chatNotificationsCount
	}

	func setupNavigationView() {
		navigationView = UIView(frame: CGRect(x: 16, y: 0, width: view.frame.size.width - 32, height: navigationController!.navigationBar.frame.size.height))
		navigationController!.navigationBar.addSubview(navigationView)
		navigationView.addSubview(leadingHStack)
		leadingHStack.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor).isActive = true
		leadingHStack.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor).isActive = true

		[backButton, greetingLabel].forEach { leadingHStack.addArrangedSubview($0) }
		backButton.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
		backButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
		backButton.addTarget(self, action: #selector(onClickBackButton), for: .touchUpInside)
		setLeadingButton()

		navigationView.addSubview(badgeView)
		badgeView.centerYAnchor.constraint(equalTo: greetingLabel.centerYAnchor).isActive = true
		badgeView.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor).isActive = true
		badgeView.addArrangedSubview(chatImageView)
		badgeView.addArrangedSubview(badgeCountView)

		badgeCountView.badgeCount = UserDefaults.chatNotificationsCount

		chatImageView.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
		chatImageView.heightAnchor.constraint(equalToConstant: 24.0).isActive = true

		navigationView.addSubview(onlineLabel)
		onlineLabel.centerYAnchor.constraint(equalTo: greetingLabel.centerYAnchor).isActive = true
		onlineLabel.trailingAnchor.constraint(equalTo: badgeView.leadingAnchor, constant: -12.0).isActive = true

		navigationView.addSubview(onlineView)
		onlineView.centerYAnchor.constraint(equalTo: greetingLabel.centerYAnchor).isActive = true
		onlineView.trailingAnchor.constraint(equalTo: onlineLabel.leadingAnchor, constant: -8.0).isActive = true
		onlineView.widthAnchor.constraint(equalToConstant: 10.0).isActive = true
		onlineView.heightAnchor.constraint(equalToConstant: 10.0).isActive = true

		navigationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onNavBarClick)))
	}

	func setLeadingButton() {
		backButton.isHidden = !isShowChatVC
		greetingLabel.text = isShowChatVC ? "Back" : "Monitored By UCHealth"
	}

	@objc func onClickBackButton() {
		if !isShowChatVC {
			return
		}
		let chatVC = AppCoordinator.conversationsListViewController
		if let currentVC = navigationController?.topViewController {
			UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseIn) { [weak self] in
				self?.chatStackView.isHidden = true
				self?.chatStackView.layoutIfNeeded()
				currentVC.view.layoutIfNeeded()
			} completion: { [weak self] _ in
				chatVC.willMove(toParent: nil)
				self?.chatStackView.removeArrangedSubview(chatVC.view)
				chatVC.view.removeFromSuperview()
				chatVC.removeFromParent()
				self?.chatStackView.removeFromSuperview()
				self?.isShowChatVC.toggle()
				self?.tabBarController?.tabBar.isHidden = false
				self?.setLeadingButton()
			}
		}
	}

	@objc func onNavBarClick() {
		let chatVC = AppCoordinator.conversationsListViewController
		if let currentVC = navigationController?.topViewController {
			if !isShowChatVC {
				currentVC.view.addSubview(chatStackView)
				chatStackView.topAnchor.constraint(equalTo: currentVC.view.safeAreaLayoutGuide.topAnchor).isActive = true
				chatStackView.leadingAnchor.constraint(equalTo: currentVC.view.leadingAnchor).isActive = true
				chatStackView.trailingAnchor.constraint(equalTo: currentVC.view.trailingAnchor).isActive = true
				chatStackView.bottomAnchor.constraint(equalTo: currentVC.view.bottomAnchor).isActive = true
				currentVC.view.bringSubviewToFront(chatStackView)
				currentVC.addChild(chatVC)
				chatStackView.addArrangedSubview(chatVC.view)
				chatVC.didMove(toParent: currentVC)
				UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseIn) { [weak self] in
					self?.chatStackView.isHidden = false
					self?.chatStackView.layoutIfNeeded()
					currentVC.view.layoutIfNeeded()
					self?.tabBarController?.tabBar.isHidden = true
				} completion: { [weak self] _ in
					self?.isShowChatVC.toggle()
					chatVC.view.frame.size = self!.chatStackView.frame.size
					chatVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
					chatVC.becomeFirstResponder()
					self?.setLeadingButton()
				}
			} else {
				return
			}
		}
	}
}
