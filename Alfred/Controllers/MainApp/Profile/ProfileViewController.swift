//
//  ProfileViewController.swift
//  Alfred
//

import HealthKit
import UIKit

enum Coming: Hashable, CaseIterable {
	case today
	case edit
	case signup
}

enum HealthStatsDateIntervalType: Hashable, CaseIterable {
	case daily
	case weekly
	case monthly
	case yearly
}

class ProfileViewController: BaseViewController {
	// MARK: Coordinator Actions

	var editButtonAction: ((Int, Int) -> Void)?
	var profileInputAction: (() -> (CodexResource?, CodexBundle?))?
	var comingFrom: Coming = .today
	var getData: Coordinator.ActionHandler?
	var getRangeData: ((HealthStatsDateIntervalType, Date, Date, (([HealthKitQuantityType: [StatModel]]?, [HealthKitQuantityType: Double]?) -> Void)?) -> Void)?
	var getTodayData: Coordinator.ActionHandler?

	// MARK: IBOutlets

	@IBOutlet var patientTrendsTableView: UITableView!
	@IBOutlet var dateLabel: UILabel!
	@IBOutlet var previousDateButton: UIButton!
	@IBOutlet var nextDateButton: UIButton!
	@IBOutlet var dateIntervalSegmentedControl: UISegmentedControl!
	@IBOutlet var separatorLineView: UIView!
	@IBOutlet var topView: UIView!
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var detailsLabel: UILabel!
	@IBOutlet var editButton: UIButton!
	@IBOutlet var prevButton: UIButton!

	// MARK: Vars

	var currentDateInterval: HealthStatsDateIntervalType = .daily {
		didSet {
			resetExpandState()
			if currentDateInterval != .daily {
				fetchData(newDateRange: (startDate, endDate))
			} else {
				updateDateLabel()
				patientTrendsTableView?.reloadData()
			}
		}
	}

	var expandedIndexPath: IndexPath?
	var currentHKData: [HealthKitQuantityType: [StatModel]] = [:] {
		didSet {
			patientTrendsTableView?.reloadData()
		}
	}

	var goals: [HealthKitQuantityType: Double] = [:] {
		didSet {
			patientTrendsTableView?.reloadData()
		}
	}

	var expandCollapseState: [HealthKitQuantityType: Bool] = [:]
	var todayHKData: [HealthKitQuantityType: [Any]] = [:] {
		didSet {
			patientTrendsTableView?.reloadData()
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
			updateDateLabel()
		}
	}

	var currentMonthDate = Date().startOfMonth ?? Date() {
		didSet {
			updateDateLabel()
		}
	}

	var currentYearDate = Date().startOfYear ?? Date() {
		didSet {
			updateDateLabel()
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

	// MARK: SetupViewController

	override func setupView() {
		title = Str.profile
		let name = ProfileHelper.firstName ?? ""
		resetExpandState()
		topView.backgroundColor = UIColor.profile
		separatorLineView.backgroundColor = UIColor.swipe
		nameLabel.attributedText = name.with(style: .bold28, andColor: .black, andLetterSpacing: 0.36)

		editButton.setTitle(Str.edit, for: .normal)
		editButton.setTitleColor(UIColor.cursorOrange, for: .normal)
		patientTrendsTableView.register(UINib(nibName: StatCell.nibName, bundle: nil), forCellReuseIdentifier: StatCell.reuseIdentifier)
		patientTrendsTableView.register(UINib(nibName: TodayStatCell.nibName, bundle: nil), forCellReuseIdentifier: TodayStatCell.reuseIdentifier)
		patientTrendsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
		patientTrendsTableView.estimatedRowHeight = 300

		patientTrendsTableView.rowHeight = UITableView.automaticDimension
		patientTrendsTableView.delegate = self
		patientTrendsTableView.dataSource = self
		setupInitialDateInterval()
	}

	private func resetExpandState() {
		patientTrendsTableView?.contentOffset = CGPoint.zero
		HealthKitQuantityType.allCases.forEach {
			expandCollapseState[$0] = false
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		getData?()
		age = ProfileHelper.birthdate
		let date = Date()
		let calendar = Calendar.current
		ageDiff = calendar.component(.year, from: date) - (age ?? 0)
	}

	func createDetailsLabel() {
		(feet, inches) = ProfileHelper.computeHeight(value: height ?? 0)

		let details = "\(ageDiff) \(Str.years) | \(feet)' \(inches)'' | \(weight ?? 0) \(Str.weightUnit)"
		detailsLabel.attributedText = details.with(style: .regular17, andColor: .lightGrey, andLetterSpacing: 0.36)
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
		updateDateLabel()
	}

	private func updateDateLabel() {
		switch currentDateInterval {
		case .daily:
			dateLabel.attributedText = Str.today.with(style: .semibold20, andColor: UIColor.pcp)
		case .weekly, .monthly:
			guard let startDate = startDate, let endDate = endDate else { return }
			dateLabel.attributedText = "\(DateFormatter.MMMdd.string(from: startDate))-\(DateFormatter.MMMdd.string(from: endDate))".with(style: .semibold20, andColor: UIColor.pcp)
		case .yearly:
			guard let startDate = startDate else { return }
			dateLabel.attributedText = "\(DateFormatter.yyyy.string(from: startDate))".with(style: .semibold20, andColor: UIColor.pcp)
		}
		nextDateButton.isHidden = currentDateInterval == .daily
		previousDateButton.isHidden = currentDateInterval == .daily
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

	@IBAction func editButtonTapped(_ sender: Any) {
		editButtonAction?(weight ?? 0, height ?? 0)
	}
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		HealthKitQuantityType.allCases.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let type = HealthKitQuantityType.allCases[indexPath.row]
		if currentDateInterval == .daily {
			let cell = tableView.dequeueReusableCell(withIdentifier: TodayStatCell.reuseIdentifier, for: indexPath) as? TodayStatCell
			cell?.selectionStyle = .none
			cell?.setup(for: type, with: todayHKData[type])
			return cell!
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: StatCell.reuseIdentifier, for: indexPath) as? StatCell
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
