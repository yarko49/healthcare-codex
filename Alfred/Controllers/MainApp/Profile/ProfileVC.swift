//
//  ProfileVC.swift
//  alfred-ios
//

import HealthKit
import UIKit

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

class ProfileVC: BaseViewController {
	// MARK: Coordinator Actions

	var backBtnAction: (() -> Void)?
	var editBtnAction: ((Int, Int) -> Void)?
	var profileInputAction: (() -> (Resource?, BundleModel?))?
	var comingFrom: Coming = .today
	var getData: (() -> Void)?
	var getRangeData: ((HealthStatsDateIntervalType, Date, Date, (([HealthKitQuantityType: [StatModel]]?, [HealthKitQuantityType: Double]?) -> Void)?) -> Void)?
	var getTodayData: (() -> Void)?

	// MARK: IBOutlets

	@IBOutlet var patientTrendsTV: UITableView!
	@IBOutlet var dateLbl: UILabel!
	@IBOutlet var previousDateBtn: UIButton!
	@IBOutlet var nextDateBtn: UIButton!
	@IBOutlet var dateIntervalSegmentedControl: UISegmentedControl!
	@IBOutlet var separatorLineView: UIView!
	@IBOutlet var topView: UIView!
	@IBOutlet var nameLbl: UILabel!
	@IBOutlet var detailsLbl: UILabel!
	@IBOutlet var editBtn: UIButton!
	@IBOutlet var prevBtn: UIButton!

	// MARK: Vars

	var currentDateInterval: HealthStatsDateIntervalType = .daily {
		didSet {
			resetExpandState()
			if currentDateInterval != .daily {
				fetchData(newDateRange: (startDate, endDate))
			} else {
				updateDateLbl()
				patientTrendsTV?.reloadData()
			}
		}
	}

	var expandedIndexPath: IndexPath?
	var currentHKData: [HealthKitQuantityType: [StatModel]] = [:] {
		didSet {
			patientTrendsTV?.reloadData()
		}
	}

	var goals: [HealthKitQuantityType: Double] = [:] {
		didSet {
			patientTrendsTV?.reloadData()
		}
	}

	var expandCollapseState: [HealthKitQuantityType: Bool] = [:]
	var todayHKData: [HealthKitQuantityType: [Any]] = [:] {
		didSet {
			patientTrendsTV?.reloadData()
		}
	}

	var age: Int?
	var weight: Int?
	var height: Int?
	var ageDiff: Int = 0
	var feet: Int = 0
	var inches: Int = 0
	var lastName: String = ""
	var currentWkDate = Date().startOfWeek ?? Date() {
		didSet {
			updateDateLbl()
		}
	}

	var currentMonthDate = Date().startOfMonth ?? Date() {
		didSet {
			updateDateLbl()
		}
	}

	var currentYearDate = Date().startOfYear ?? Date() {
		didSet {
			updateDateLbl()
		}
	}

	var startDate: Date? {
		switch currentDateInterval {
		case .daily: return nil
		case .weekly: return currentWkDate
		case .monthly: return currentMonthDate
		case .yearly: return currentYearDate
		}
	}

	var endDate: Date? {
		switch currentDateInterval {
		case .daily: return nil
		case .weekly: return startDate?.endOfWeek
		case .monthly: return startDate?.endOfMonth
		case .yearly: return startDate?.endOfYear
		}
	}

	// MARK: SetupVC

	override func setupView() {
		title = Str.profile
		let name = ProfileHelper.getFirstName()
		navigationController?.navigationBar.isHidden = false
		let navBar = navigationController?.navigationBar
		navBar?.setBackgroundImage(UIImage(), for: .default)
		navBar?.shadowImage = UIImage()
		navBar?.isHidden = false
		navBar?.isTranslucent = false
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backBtnTapped))
		navigationItem.leftBarButtonItem?.tintColor = UIColor.black
		resetExpandState()
		topView.backgroundColor = UIColor.profile
		separatorLineView.backgroundColor = UIColor.swipeColor
		nameLbl.attributedText = name.with(style: .bold28, andColor: .black, andLetterSpacing: 0.36)

		editBtn.setTitle(Str.edit, for: .normal)
		editBtn.setTitleColor(UIColor.cursorOrange, for: .normal)
		patientTrendsTV.register(UINib(nibName: "StatCell", bundle: nil), forCellReuseIdentifier: "StatCell")
		patientTrendsTV.register(UINib(nibName: "TodayStatCell", bundle: nil), forCellReuseIdentifier: "TodayStatCell")
		patientTrendsTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
		patientTrendsTV.estimatedRowHeight = 300

		patientTrendsTV.rowHeight = UITableView.automaticDimension
		patientTrendsTV.delegate = self
		patientTrendsTV.dataSource = self
		setupInitialDateInterval()
	}

	private func resetExpandState() {
		patientTrendsTV?.contentOffset = CGPoint.zero
		DataContext.shared.userAuthorizedQuantities.forEach {
			expandCollapseState[$0] = false
		}
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
		(feet, inches) = ProfileHelper.computeHeight(value: height ?? 0)

		let details = "\(ageDiff) \(Str.years) | \(feet)' \(inches)'' | \(weight ?? 0) \(Str.weightUnit)"
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
		updateDateLbl()
	}

	private func updateDateLbl() {
		switch currentDateInterval {
		case .daily:
			dateLbl.attributedText = Str.today.with(style: .semibold20, andColor: UIColor.pcpColor)
		case .weekly, .monthly:
			guard let startDate = startDate, let endDate = endDate else { return }
			dateLbl.attributedText = "\(DateFormatter.MMMdd.string(from: startDate))-\(DateFormatter.MMMdd.string(from: endDate))".with(style: .semibold20, andColor: UIColor.pcpColor)
		case .yearly:
			guard let startDate = startDate else { return }
			dateLbl.attributedText = "\(DateFormatter.yyyy.string(from: startDate))".with(style: .semibold20, andColor: UIColor.pcpColor)
		}
		nextDateBtn.isHidden = currentDateInterval == .daily
		previousDateBtn.isHidden = currentDateInterval == .daily
	}

	// MARK: Actions

	private func fetchData(newDateRange: (Date?, Date?)) {
		guard let start = newDateRange.0, let end = newDateRange.1 else { return }
		getRangeData?(currentDateInterval, start, end, { [weak self] newData, goals in
			guard let newData = newData, let goals = goals else { return }
			self?.currentHKData = newData
			self?.goals = goals
			switch self?.currentDateInterval {
			case .weekly: self?.currentWkDate = start
			case .monthly: self?.currentMonthDate = start
			case .yearly: self?.currentYearDate = start
			default: break
			}
		})
	}

	@objc func backBtnTapped() {
		backBtnAction?()
	}

	@IBAction func previousDateBtnTapped(_ sender: Any) {
		let newDateRange = getNewFetchDates(isPrevious: true)
		fetchData(newDateRange: newDateRange)
	}

	@IBAction func nextDateBtnTapped(_ sender: Any) {
		let newDateRange = getNewFetchDates(isPrevious: false)
		fetchData(newDateRange: newDateRange)
	}

	func getNewFetchDates(isPrevious: Bool) -> (Date?, Date?) {
		var newStartDate: Date?
		var newEndDate: Date?
		switch currentDateInterval {
		case .daily: break
		case .weekly:
			newStartDate = isPrevious ? currentWkDate.previousWeek : currentWkDate.nextWeek
			newEndDate = newStartDate?.endOfWeek
		case .monthly:
			newStartDate = isPrevious ? currentMonthDate.previousMonth : currentMonthDate.startOfNextMonth
			newEndDate = newStartDate?.endOfMonth
		case .yearly:
			newStartDate = isPrevious ? currentYearDate.previousYear : currentYearDate.startOfNextYear
			newEndDate = newStartDate?.endOfYear
		}
		return (newStartDate, newEndDate)
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
	}

	@IBAction func editBtnTapped(_ sender: Any) {
		editBtnAction?(weight ?? 0, height ?? 0)
	}
}

extension ProfileVC: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		DataContext.shared.userAuthorizedQuantities.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let type = DataContext.shared.userAuthorizedQuantities[indexPath.row]
		if currentDateInterval == .daily {
			let cell = tableView.dequeueReusableCell(withIdentifier: "TodayStatCell", for: indexPath) as? TodayStatCell
			cell?.selectionStyle = .none
			cell?.setup(for: type, with: todayHKData[type])
			return cell!
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "StatCell", for: indexPath) as? StatCell
			cell?.selectionStyle = .none
			cell?.expandCollapseAction = { [weak self] expanded in
				let currentContentOffset = tableView.contentOffset
				self?.expandCollapseState[type] = expanded
				tableView.reloadRows(at: [indexPath], with: .none)
				tableView.contentOffset = currentContentOffset
			}
			cell?.setup(for: type, with: currentHKData[type], intervalType: currentDateInterval, expanded: expandCollapseState[type] ?? false, goal: goals[type] ?? 0.0)
			return cell!
		}
	}
}
