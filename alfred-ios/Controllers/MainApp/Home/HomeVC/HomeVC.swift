import UIKit

class HomeVC: BaseVC {
    
    // MARK: - Coordinator Actions
    var testRequestAction: (()->())?
    var questionaireAction: (()->())?
    var behavioralNudgeAction: (()->())?
    
    // MARK: - Properties
    
    var notificationsList: [HomeNotification] = []
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var notificationsCollectionView: UICollectionView!
    
    // MARK: - Initializer
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func setupView() {
        super.setupView()
        
        title = "Alfred"
        
        notificationsCollectionView.register(UINib(nibName: "HomeNotificationCell", bundle: nil), forCellWithReuseIdentifier: "HomeNotificationCell")
        notificationsCollectionView.delegate = self
        notificationsCollectionView.dataSource = self
        
        self.view.layer.backgroundColor = UIColor.veryLightGrey?.cgColor
        notificationsCollectionView.backgroundColor = UIColor.veryLightGrey
         notificationsCollectionView.showsVerticalScrollIndicator = false
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        notificationsCollectionView.collectionViewLayout = layout
    }
    
    override func populateData() {
        super.populateData()
        testRequestAction?()
    }
    
    @IBAction func didTapTestRequest(_ sender: UIButton) {
        testRequestAction?()
    }
    
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notificationsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeNotificationCell", for: indexPath) as! HomeNotificationCell
        cell.setupCell(text: notificationsList[indexPath.row].text, type: notificationsList[indexPath.row].getHomeNotificationType)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch notificationsList[indexPath.row].getHomeNotificationType {
        case .behavioralNudge:
            behavioralNudgeAction?()
        case .questionaire:
            questionaireAction?()
        case .noType:
            print("Cell selected: \(indexPath.row)")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        let bottomSafeAreaSpacing = self.view.safeAreaInsets
        return UIEdgeInsets(top: 12, left: 20, bottom: bottomSafeAreaSpacing.bottom, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: notificationsCollectionView.frame.width - 40, height: 90)
    }

}
