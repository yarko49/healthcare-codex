import UIKit


class HomeVC: BaseVC {
    
    // MARK: - Coordinator Actions
    var getCardsAction: (()->())?
    var questionnaireAction: (()->())?
    var troubleshootingAction: ((String?, String?, String?, IconType?)->())?
    var measurementCellAction: ((InputType)->())?
    
    // MARK: - Properties
    
    var measurementCardsList: [NotificationCard] = []
    var coachCardsList: [NotificationCard] = []
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var coachCardSV: UIStackView!
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var coachCardSVXConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    var refreshControl = UIRefreshControl()
    
    // MARK: - Initializer
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        cardCollectionView.alwaysBounceVertical = true
        cardCollectionView.addSubview(refreshControl)

    }
    
    override func viewWillAppear(_ animated : Bool){
        super.viewWillAppear(animated)
       
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func setupView() {
        super.setupView()
        
        title = Str.today
        
        coachCardSVXConstraint.isActive = false
        
        cardCollectionView.register(UINib(nibName: "MeasurementCardCell", bundle: nil), forCellWithReuseIdentifier: "MeasurementCardCell")
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        
        self.view.layer.backgroundColor = UIColor.white.cgColor
        cardCollectionView.backgroundColor = .white
        cardCollectionView.showsVerticalScrollIndicator = false
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        cardCollectionView.collectionViewLayout = layout
    
    }
    
    override func populateData() {
        super.populateData()
        getCardsAction?()
    }
    
    func setupCards(with notificationList: [NotificationCard]?) {
        guard let notificationList = notificationList else { return }
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
        if coachCardsList.count > 0 {
            scrollView.setContentOffset(CGPoint(x: CGFloat(0)*(scrollView.frame.width), y: 0), animated: true)
            scrollView.isHidden = false
            coachCardSV.arrangedSubviews.filter({ $0 is CoachCardView }).forEach({ $0.removeFromSuperview() })
        } else {
            scrollView.isHidden = true
        }
        
        for card in coachCardsList {
            let view = CoachCardView(card: card.data)
            view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
            view.delegate = self
            coachCardSV.addArrangedSubview(view)
        }
    }
    
    @objc func refresh(_ sender: AnyObject) {
        getCardsAction?()
    }
    
}


extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return measurementCardsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MeasurementCardCell", for: indexPath) as! MeasurementCardCell
        cell.setupCell(with: measurementCardsList[indexPath.row].data)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch measurementCardsList[indexPath.row].data.action {
        case .activity:
            break
        case .bloodPressure:
            measurementCellAction?(.bloodPressure)
        case .weight:
            measurementCellAction?(.weight)
        case .questionnaire:
            questionnaireAction?()
        case .none:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        let bottomSafeAreaSpacing = self.view.safeAreaInsets
        return UIEdgeInsets(top: 10, left: 16, bottom: bottomSafeAreaSpacing.bottom, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cardCollectionView.frame.width - 32, height: 94)
    }
}

extension HomeVC: CoachCardViewDelegate {
    func actionBtnTapped(previewTitle: String?, title: String?, text: String?, icon: IconType?) {
        troubleshootingAction?(previewTitle, title, text, icon)
    }
    
    func closeBtnTapped(uuid: String) {
        if let index = coachCardsList.firstIndex(where: {$0.data.uuid == uuid}), let SVIndex = (coachCardSV.arrangedSubviews as? [CoachCardView])?.firstIndex(where: {$0.card?.uuid == uuid} ), coachCardsList.count > 1 {
            scrollView.setContentOffset(CGPoint(x: CGFloat(index)*(scrollView.frame.width), y: 0), animated: true)
            coachCardSV.arrangedSubviews[SVIndex].isHidden = true
            coachCardsList.removeAll(where: {$0.data.uuid == uuid})
        } else {
            scrollView.isHidden = true
            coachCardsList.removeAll(where: {$0.data.uuid == uuid})
        }
    }
}
