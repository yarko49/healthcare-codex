//
//  ProfileVC.swift
//  alfred-ios
//

import UIKit
import HealthKit

enum Coming {
    case today
    case edit
    case signup
}


enum HealthStatsDateIntervalType {
    case daily
    case weekly
    case monthly
    case yearly
}

class ProfileVC: BaseVC {
    
    //MARK: Coordinator Actions
    var backBtnAction: (()->())?
    var editBtnAction: ((Int, Int)->())?
    var profileInputAction: (()->(Resource?, BundleModel?))?
    var comingFrom : Coming = .today
    var getData: (()->())?
   
    //MARK: IBOutlets
    @IBOutlet weak var patientTrendsTV: UITableView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var previousDateBtn: UIButton!
    @IBOutlet weak var nextDateBtn: UIButton!
    @IBOutlet weak var dateIntervalSegmentedControl: UISegmentedControl!
    @IBOutlet weak var separatorLineView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var detailsLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var prevBtn: UIButton!
    
    //MARK: Vars
    var currentDateInterval: HealthStatsDateIntervalType = .daily
    var startDate: Date = Date()
    var endDate: Date = Date()
    var expandedIndexPath: IndexPath?
    var currentHKData: [HealthKitQuantityType: PatientTrendCellData] = [:]
    var todayHKData: [HealthKitQuantityType : [Any]] = [:] {
        didSet {
            patientTrendsTV?.reloadData()
        }
    }
    var chartData: [HealthKitQuantityType : ChartData] = [:]
    var age : Int?
    var weight : Int?
    var height : Int?
    var ageDiff : Int = 0
    var feet : Int = 0
    var inches : Int = 0
    var lastName: String = ""
    
    //MARK: SetupVC
    override func setupView() {
        title = Str.profile
        let name = ProfileHelper.getFirstName()
        navigationController?.navigationBar.isHidden = false
        let navBar = navigationController?.navigationBar
        navBar?.setBackgroundImage(UIImage(), for: .default)
        navBar?.shadowImage = UIImage()
        navBar?.isHidden = false
        navBar?.isTranslucent = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backBtnTapped))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        topView.backgroundColor = UIColor.profile
        separatorLineView.backgroundColor = UIColor.swipeColor
        nameLbl.attributedText = name.with(style: .bold28, andColor: .black, andLetterSpacing: 0.36)
    
        editBtn.setTitle( Str.edit, for: .normal)
        editBtn.setTitleColor(UIColor.cursorOrange , for: .normal)
        patientTrendsTV.register(UINib(nibName: "PatientTrendCell", bundle: nil), forCellReuseIdentifier: "PatientTrendCell")
        patientTrendsTV.register(UINib(nibName: "TodayStatCell", bundle: nil), forCellReuseIdentifier: "TodayStatCell")
        patientTrendsTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        patientTrendsTV.estimatedRowHeight = 300
        patientTrendsTV.rowHeight = UITableView.automaticDimension
        patientTrendsTV.delegate = self
        patientTrendsTV.dataSource = self
        setupInitialDateInterval()
        refreshHKData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getData?()
        age = ProfileHelper.getBirthdate()
        let date = Date()
        let calendar = Calendar.current
        ageDiff = calendar.component(.year, from: date) - (age ?? 0)
    }
    
    func createDetailsLabel() {
        (feet,inches) = ProfileHelper.computeHeight(value: height ?? 0)
        
        let details = "\(ageDiff) \(Str.years) | \(feet)' \(inches )'' | \(weight ?? 0) \(Str.weightUnit)"
        detailsLbl.attributedText = details.with(style: .regular17, andColor: .lightGrey, andLetterSpacing: 0.36)
    }
    
    override func localize() {
        dateIntervalSegmentedControl.setTitle(Str.today, forSegmentAt: 0)
        dateIntervalSegmentedControl.setTitle(Str.wk, forSegmentAt: 1)
        dateIntervalSegmentedControl.setTitle(Str.mo, forSegmentAt: 2)
        dateIntervalSegmentedControl.setTitle(Str.yr, forSegmentAt: 3)
    }
    
    private func setupInitialDateInterval() {
        dateIntervalSegmentedControl.selectedSegmentIndex = 0
        currentDateInterval = .daily
        resetDates()
        updateDateLbl()
    }
    
    private func calulateIntervals(isMovingForward: Bool) {
        switch currentDateInterval {
        case .daily:
            break
        case .weekly:
            updateDates(calComponent: .day, value: isMovingForward ? 7 : -7)
        case .monthly:
            updateDates(calComponent: .month, value: isMovingForward ? 1 : -1)
        case .yearly:
            updateDates(calComponent: .year, value: isMovingForward ? 1 : -1)
        }
        updateDateLbl()
        refreshHKData()
    }
    
    private func updateDates(calComponent: Calendar.Component, value: Int) {
        startDate = Calendar.current.date(byAdding: calComponent, value: value , to: startDate) ?? Date()
        endDate = Calendar.current.date(byAdding: calComponent, value: value, to: endDate) ?? Date()
    }
    
    private func resetDates() {
        switch currentDateInterval {
        case .daily:
            startDate = Calendar.current.startOfDay(for: Date())
            endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) ?? Date()
        case .weekly:
            startDate = Calendar.current.startOfDay(for: Date())
            endDate = Calendar.current.date(byAdding: .day, value: 6 , to: startDate) ?? Date()
        case .monthly:
            startDate = Calendar.current.startOfDay(for: Date())
            endDate = Calendar.current.date(byAdding: .month, value: 1 , to: startDate) ?? Date()
         case .yearly:
            let currYear = Calendar.current.component(.year, from: Date())
            startDate = Calendar.current.date(from: DateComponents(year: currYear, month: 1, day: 1)) ?? Date()
            endDate = Calendar.current.date(byAdding: .year, value: 1 , to: startDate) ?? Date()
        }
        updateDateLbl()
    }
    
    private func updateDateLbl() {
        switch currentDateInterval {
        case .daily:
            dateLbl.attributedText = Str.today.with(style: .semibold20, andColor: UIColor.pcpColor)
        case .weekly, .monthly:
            dateLbl.attributedText = "\(DateFormatter.MMMdd.string(from: startDate))-\(DateFormatter.MMMdd.string(from: endDate))".with(style: .semibold20, andColor: UIColor.pcpColor)
        case .yearly:
            dateLbl.attributedText = "\(DateFormatter.yyyy.string(from: startDate))".with(style: .semibold20, andColor: UIColor.pcpColor)
        }
        nextDateBtn.isHidden = currentDateInterval == .daily
        previousDateBtn.isHidden = currentDateInterval == .daily
    }
    
    private func refreshHKData() {
        patientTrendsTV.reloadData()
    }
    
    //MARK: Actions
    
    @objc func backBtnTapped() {
        backBtnAction?()
    }
    
    @IBAction func previousDateBtnTapped(_ sender: Any) {
        calulateIntervals(isMovingForward: false)
    }
    
    @IBAction func nextDateBtnTapped(_ sender: Any) {
        calulateIntervals(isMovingForward: true)
    }
    
    @IBAction func dateIntervalValueChanged(_ sender: Any) {
        switch dateIntervalSegmentedControl.selectedSegmentIndex {
        case 0:
            currentDateInterval = .daily
        case 1:
            currentDateInterval = .weekly
        case 2:
            currentDateInterval = .monthly
        case 3:
            currentDateInterval = .yearly
        default:
            break
        }
        resetDates()
        refreshHKData()
    }
    
    
    @IBAction func editBtnTapped(_ sender: Any) {
        editBtnAction?(weight ?? 0, height ?? 0)
    }
}

extension ProfileVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataContext.shared.userAuthorizedQuantities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if currentDateInterval == .daily {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodayStatCell", for: indexPath) as! TodayStatCell
            let type = DataContext.shared.userAuthorizedQuantities[indexPath.row]
            cell.selectionStyle = .none
            cell.setup(for: type, with: todayHKData[type])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PatientTrendCell", for: indexPath) as! PatientTrendCell
                    let type = DataContext.shared.userAuthorizedQuantities[indexPath.row]
                    cell.selectionStyle = .none
                    cell.setupCell(data: currentHKData[type] ?? PatientTrendCellData(averageValue: nil, highValue: nil, lowValue: nil),
                                   type: type,
                                   healthStatsDateIntervalType: currentDateInterval, chartData: chartData[type] ?? ChartData(xValues: [""], yValues: []),
                                   shouldShowChart: indexPath == expandedIndexPath)
                    cell.delegate = self
                    return cell

        }

    }
    
}

extension ProfileVC: PatientTrendCellDelegate {
    
    func didTapDetailsView(cell: PatientTrendCell) {
        guard let indexPath = patientTrendsTV.indexPath(for: cell) else { return }
        expandedIndexPath = indexPath == expandedIndexPath ? nil : indexPath
        patientTrendsTV.reloadData()
        patientTrendsTV.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
}
