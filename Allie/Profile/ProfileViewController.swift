//
//  ProfileViewController.swift
//  Allie
//

import HealthKit
import ModelsR4
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
	var profileInputAction: (() -> (ModelsR4.Observation?, ModelsR4.Bundle?))?
	var comingFrom: Coming = .today
	var getData: AllieActionHandler?
	var getRangeData: ((HealthStatsDateIntervalType, Date, Date, (([HealthKitQuantityType: [StatModel]]?, [HealthKitQuantityType: Int]?) -> Void)?) -> Void)?
	var getTodayData: AllieActionHandler?

	// MARK: IBOutlets

	@IBOutlet var tableView: UITableView!
	@IBOutlet var dateLabel: UILabel!
	@IBOutlet var previousDateButton: UIButton!
	@IBOutlet var nextDateButton: UIButton!
	@IBOutlet var dateIntervalSegmentedControl: UISegmentedControl!
	@IBOutlet var separatorLineView: UIView!
	@IBOutlet var topView: UIView!
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var detailsLabel: UILabel!

	// MARK: Vars

	var patient: CHPatient? {
		CareManager.shared.patient
	}

	var currentDateInterval: HealthStatsDateIntervalType = .daily {
		didSet {
			resetExpandState()
			if currentDateInterval != .daily {
				fetchData(newDateRange: (startDate, endDate))
			} else {
				updateDateLabel()
				tableView?.reloadData()
			}
		}
	}

	var expandedIndexPath: IndexPath?
	var currentHKData: [HealthKitQuantityType: [StatModel]] = [:] {
		didSet {
			tableView?.reloadData()
		}
	}

	var goals: [HealthKitQuantityType: Int] = [:] {
		didSet {
			tableView?.reloadData()
		}
	}

	var expandCollapseState: [HealthKitQuantityType: Bool] = [:]
	var todayHKData: [HealthKitQuantityType: [Any]] = [:] {
		didSet {
			tableView?.reloadData()
		}
	}

	var age: Int?
	var weight: Int?
	var height: Int?
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
		title = String.profile
		let name = patient?.name.givenName ?? ""
		resetExpandState()
		topView.backgroundColor = UIColor.white
		separatorLineView.backgroundColor = UIColor.swipe
		nameLabel.attributedText = name.attributedString(style: .bold28, foregroundColor: .black, letterSpacing: 0.36)

		tableView.register(UINib(nibName: StatCell.nibName, bundle: nil), forCellReuseIdentifier: StatCell.reuseIdentifier)
		tableView.register(UINib(nibName: TodayStatCell.nibName, bundle: nil), forCellReuseIdentifier: TodayStatCell.reuseIdentifier)
		tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
		tableView.estimatedRowHeight = 300

		tableView.rowHeight = UITableView.automaticDimension
		tableView.delegate = self
		tableView.dataSource = self
		setupInitialDateInterval()
	}

	private func resetExpandState() {
		tableView?.contentOffset = CGPoint.zero
		HealthKitQuantityType.allCases.forEach {
			expandCollapseState[$0] = false
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		getRangeData = { interval, start, end, completion in
			var chartData: [HealthKitQuantityType: [StatModel]] = [:]
			var goals: [HealthKitQuantityType: Int] = [:]
			let chartGroup = DispatchGroup()
			HealthKitQuantityType.allCases.forEach { quantityType in
				chartGroup.enter()
				let innergroup = DispatchGroup()
				var values: [StatModel] = []
				quantityType.healthKitQuantityTypeIdentifiers.forEach { identifier in
					innergroup.enter()
					HealthKitManager.shared.queryData(identifier: identifier, startDate: start, endDate: end, intervalType: interval) { dataPoints in
						let stat = StatModel(type: quantityType, dataPoints: dataPoints)
						values.append(stat)
						innergroup.leave()
					}
				}

				innergroup.notify(queue: .main) {
					chartData[quantityType] = values
					goals[quantityType] = ProfileHelper.getGoal(for: quantityType)
					chartGroup.leave()
				}
			}

			chartGroup.notify(queue: .main) {
				completion?(chartData, goals)
			}
		}

		updateTodayData()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		age = patient?.age
		weight = patient?.profile.weightInPounds
		height = patient?.profile.heightInInches
		createDetailsLabel()
		tableView.reloadData()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "ProfileView"])
	}

	func createDetailsLabel() {
		(feet, inches) = ((height ?? 0) / 12, (height ?? 0) % 12)
		let details = "\(age ?? 0) \(String.years) | \(feet)' \(inches)'' | \(weight ?? 0) \(String.weightUnit)"
		detailsLabel.attributedText = details.attributedString(style: .regular17, foregroundColor: .lightGrey, letterSpacing: 0.36)
	}

	override func localize() {
		dateIntervalSegmentedControl.setTitle(String.today, forSegmentAt: 0)
		dateIntervalSegmentedControl.setTitle(String.wk, forSegmentAt: 1)
		dateIntervalSegmentedControl.setTitle(String.mo, forSegmentAt: 2)
		dateIntervalSegmentedControl.setTitle(String.yr, forSegmentAt: 3)
	}

	private func setupInitialDateInterval() {
		dateIntervalSegmentedControl.selectedSegmentIndex = 0
		currentDateInterval = .daily
		updateDateLabel()
	}

	private func updateDateLabel() {
		switch currentDateInterval {
		case .daily:
			dateLabel.attributedText = String.today.attributedString(style: .semibold20, foregroundColor: UIColor.pcp)
		case .weekly, .monthly:
			guard let startDate = startDate, let endDate = endDate else { return }
			dateLabel.attributedText = "\(DateFormatter.MMMdd.string(from: startDate))-\(DateFormatter.MMMdd.string(from: endDate))".attributedString(style: .semibold20, foregroundColor: UIColor.pcp)
		case .yearly:
			guard let startDate = startDate else { return }
			dateLabel.attributedText = "\(DateFormatter.yyyy.string(from: startDate))".attributedString(style: .semibold20, foregroundColor: UIColor.pcp)
		}
		nextDateButton.isHidden = currentDateInterval == .daily
		previousDateButton.isHidden = currentDateInterval == .daily
	}

	// MARK: Actions

	private func fetchData(newDateRange: (Date?, Date?)) {
		guard let start = newDateRange.0, let end = newDateRange.1 else { return }
		getRangeData?(currentDateInterval, start, end, { [weak self] newData, goals in
			guard let newData = newData, let goals = goals else {
				return
			}
			self?.currentHKData = newData
			self?.goals = goals
			switch self?.currentDateInterval {
			case .weekly:
				self?.currentWkDate = start
			case .monthly:
				self?.currentMonthDate = start
			case .yearly:
				self?.currentYearDate = start
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

	func updateTodayData() {
		var todayData: [HealthKitQuantityType: [Any]] = [:]
		let topGroup = DispatchGroup()
		HealthKitQuantityType.allCases.forEach { quantityType in
			if quantityType != .activity {
				topGroup.enter()
				let innergroup = DispatchGroup()
				var values: [Any] = []
				quantityType.healthKitQuantityTypeIdentifiers.forEach { identifier in
					innergroup.enter()
					HealthKitManager.shared.mostRecentSample(for: identifier, options: []) { result in
						switch result {
						case .success(let sample):
							if let quantitySample = sample.first as? HKQuantitySample {
								values.append(quantitySample)
							}
						case .failure(let error):
							ALog.error("\(error.localizedDescription)")
						}
						innergroup.leave()
					}
				}

				innergroup.notify(queue: .main) {
					todayData[quantityType] = values
					topGroup.leave()
				}
			} else {
				topGroup.enter()
				HealthKitManager.shared.todaysStepCount(options: []) { result in
					switch result {
					case .failure(let error):
						ALog.error("\(error.localizedDescription)")
					case .success(let statistics):
						todayData[quantityType] = [statistics]
					}
					topGroup.leave()
				}
			}
		}

		topGroup.notify(queue: .main) { [weak self] in
			self?.todayHKData = todayData
		}
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
			cell?.setup(for: type, with: currentHKData[type], intervalType: currentDateInterval, expanded: expandCollapseState[type] ?? false, goal: goals[type] ?? 0)
			return cell!
		}
	}
}
