import HealthKit
import UIKit

class HomeViewController: BaseViewController {
	// MARK: - Coordinator Actions

	var getCardsAction: (() -> Void)?
	var questionnaireAction: (() -> Void)?
	var troubleshootingAction: ((String?, String?, String?, IconType?) -> Void)?
	var measurementCellAction: ((HKQuantityTypeIdentifier) -> Void)?

	// MARK: - Properties

	var measurementCardsList: [NotificationCard] = []
	var coachCardsList: [NotificationCard] = []

	// MARK: - IBOutlets

	@IBOutlet var coachCardStackView: UIStackView!
	@IBOutlet var cardCollectionView: UICollectionView!
	@IBOutlet var coachCardSVXConstraint: NSLayoutConstraint!
	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var scrollViewHeight: NSLayoutConstraint!

	var refreshControl = UIRefreshControl()

	// MARK: - Initializer

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
		cardCollectionView.alwaysBounceVertical = true
		cardCollectionView.addSubview(refreshControl)
		// This is for testing only
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		getCardsAction?()
	}

	override func setupView() {
		super.setupView()

		title = Str.today

		coachCardSVXConstraint.isActive = false

		cardCollectionView.register(UINib(nibName: MeasurementCardCell.nibName, bundle: nil), forCellWithReuseIdentifier: MeasurementCardCell.reuseIdentifier)
		cardCollectionView.delegate = self
		cardCollectionView.dataSource = self

		view.layer.backgroundColor = UIColor.white.cgColor
		cardCollectionView.backgroundColor = .white

		if let layout = cardCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
			layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
			layout.minimumLineSpacing = 16
			layout.minimumInteritemSpacing = 16
		}
	}

	func setupCards(with notificationList: [NotificationCard]?) {
		guard let notificationList = notificationList else {
			return
		}
		measurementCardsList = []
		coachCardsList = []
		for card in notificationList {
			switch card.data.type {
			case .measurement:
				measurementCardsList.append(card)
			case .coach:
				coachCardsList.append(card)
			}
		}

		setupCoachCards()
		cardCollectionView.reloadData()
	}

	private func setupCoachCards() {
		if !coachCardsList.isEmpty {
			scrollView.setContentOffset(CGPoint(x: CGFloat(0) * scrollView.frame.width, y: 0), animated: true)
			scrollView.isHidden = false
			coachCardStackView.arrangedSubviews.filter { $0 is CoachCardView }.forEach { $0.removeFromSuperview() }
		} else {
			scrollView.isHidden = true
		}

		for card in coachCardsList {
			let view = CoachCardView(card: card.data)
			view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
			view.delegate = self
			coachCardStackView.addArrangedSubview(view)
		}
	}

	@objc func refresh(_ sender: AnyObject) {
		getCardsAction?()
	}

	@objc func fetchCarePlan(_ sender: Any) {}
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		measurementCardsList.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MeasurementCardCell.reuseIdentifier, for: indexPath) as? MeasurementCardCell
		cell?.setupCell(with: measurementCardsList[indexPath.row].data)
		return cell!
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let action = measurementCardsList[indexPath.row].data.action {
			switch action {
			case .activity:
				break
			case .bloodPressure:
				measurementCellAction?(.bloodPressureSystolic)
			case .weight:
				measurementCellAction?(.bodyMass)
			case .questionnaire:
				if measurementCardsList[indexPath.row].data.progressPercent != 1 {
					questionnaireAction?()
				}
			case .heartRate:
				break
			case .heartRateResting:
				break
			case .other:
				break
			}
		}
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		let bottomSafeAreaSpacing = view.safeAreaInsets
		return UIEdgeInsets(top: 10, left: 16, bottom: bottomSafeAreaSpacing.bottom, right: 16)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		CGSize(width: cardCollectionView.frame.width - 32, height: 94)
	}
}

extension HomeViewController: CoachCardViewDelegate {
	func actionButtonTapped(previewTitle: String?, title: String?, text: String?, icon: IconType?) {
		troubleshootingAction?(previewTitle, title, text, icon)
	}

	func closeButtonTapped(uuid: String) {
		if let index = coachCardsList.firstIndex(where: { $0.data.uuid == uuid }), let SVIndex = (coachCardStackView.arrangedSubviews as? [CoachCardView])?.firstIndex(where: { $0.card?.uuid == uuid }), coachCardsList.count > 1 {
			scrollView.setContentOffset(CGPoint(x: CGFloat(index) * scrollView.frame.width, y: 0), animated: true)
			coachCardStackView.arrangedSubviews[SVIndex].isHidden = true
			coachCardsList.removeAll(where: { $0.data.uuid == uuid })
		} else {
			scrollView.isHidden = true
			coachCardsList.removeAll(where: { $0.data.uuid == uuid })
		}
	}
}
