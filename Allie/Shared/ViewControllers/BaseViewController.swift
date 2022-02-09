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

    var heightConstraint: NSLayoutConstraint = NSLayoutConstraint()

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

    var navigationView: UIView = {
        let navigationView = UIView()
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        navigationView.backgroundColor = .mainBlue
        return navigationView
    }()

    var chatView: UIView = {
        let chatView = UIView()
        chatView.translatesAutoresizingMaskIntoConstraints = false
        chatView.backgroundColor = .red
        return chatView
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

    private var badgeLabel: UILabel = {
        let badgeLabel = UILabel()
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.layer.cornerRadius = 12.0
        badgeLabel.text = "3"
        badgeLabel.textColor = .white
        badgeLabel.textAlignment = .center
        badgeLabel.font = .systemFont(ofSize: 12.0, weight: .bold)
        return badgeLabel
    }()

    private var redCircleView: UIView = {
        let redCircleView = UIView()
        redCircleView.translatesAutoresizingMaskIntoConstraints = false
        redCircleView.backgroundColor = .red
        redCircleView.layer.cornerRadius = 12.0
        return redCircleView
    }()

    private var badgeView: UIStackView = {
        let badgeView = UIStackView()
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        badgeView.axis = .horizontal
        badgeView.alignment = .center
        badgeView.spacing = -12.0
        return badgeView
    }()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.back"), style: .plain, target: nil, action: nil)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setupNavigationView()
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

    func setupNavigationView() {
        view.addSubview(navigationView)
        navigationView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        navigationView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        navigationView.heightAnchor.constraint(equalToConstant: hasTopNotch ? 120.0: 100.0).isActive = true

        navigationView.addSubview(greetingLabel)
        greetingLabel.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor, constant: 16.0).isActive = true
        greetingLabel.bottomAnchor.constraint(equalTo: navigationView.bottomAnchor, constant: -20.0).isActive = true

        navigationView.addSubview(badgeView)
        badgeView.centerYAnchor.constraint(equalTo: greetingLabel.centerYAnchor).isActive = true
        badgeView.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -16).isActive = true
        badgeView.addArrangedSubview(chatImageView)
        badgeView.addArrangedSubview(redCircleView)

        redCircleView.addSubview(badgeLabel)
        redCircleView.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        redCircleView.heightAnchor.constraint(equalToConstant: 24.0).isActive = true

        badgeLabel.centerXAnchor.constraint(equalTo: redCircleView.centerXAnchor).isActive = true
        badgeLabel.centerYAnchor.constraint(equalTo: redCircleView.centerYAnchor).isActive = true

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

    @objc func onNavBarClick() {
        let currentVC = self.navigationController?.topViewController
        if !isShowChatVC {
            currentVC!.view.addSubview(chatView)
            heightConstraint.constant = 0.0
            chatView.topAnchor.constraint(equalTo: navigationView.bottomAnchor).isActive = true
            chatView.leadingAnchor.constraint(equalTo: currentVC!.view.leadingAnchor).isActive = true
            chatView.trailingAnchor.constraint(equalTo: currentVC!.view.trailingAnchor).isActive = true
            heightConstraint = chatView.heightAnchor.constraint(equalToConstant: 0.0)
            heightConstraint.isActive = true
            currentVC?.view.bringSubviewToFront(chatView)
            UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseIn) { [weak self] in
                self?.heightConstraint.constant = UIScreen.main.bounds.height - self!.navigationView.frame.height
                self?.chatView.needsUpdateConstraints()
                currentVC?.view.layoutIfNeeded()
            } completion: { [weak self] _ in
                self?.tabBarController?.tabBar.isHidden = true
                self?.isShowChatVC.toggle()
            }
        } else {
            heightConstraint.constant = 0.0
            UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseIn) { [weak self] in
                self?.chatView.needsUpdateConstraints()
                currentVC!.view.layoutIfNeeded()
                self?.heightConstraint.isActive = false
            } completion: { [weak self] _ in
                self?.chatView.removeFromSuperview()
                self?.isShowChatVC.toggle()
                self?.tabBarController?.tabBar.isHidden = false
            }
        }
    }

	deinit {
		ALog.trace("\(String(describing: type(of: self))) deinitialized")
	}
}
