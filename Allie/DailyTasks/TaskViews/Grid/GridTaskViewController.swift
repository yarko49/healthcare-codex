//
//  GridTaskViewController.swift
//  Allie
//
//  Created by Waqar Malik on 1/16/21.
//

import CareKit
import CareKitStore
import CareKitUI
import UIKit

class GridTaskViewController: OCKTaskViewController<GridTaskController, GridTaskViewSynchronizer>, UICollectionViewDataSource {
	override public init(controller: GridTaskController, viewSynchronizer: GridTaskViewSynchronizer) {
		super.init(controller: controller, viewSynchronizer: viewSynchronizer)
	}

	override public init(viewSynchronizer: GridTaskViewSynchronizer, task: OCKAnyTask, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		super.init(viewSynchronizer: viewSynchronizer, task: task, eventQuery: eventQuery, storeManager: storeManager)
	}

	override public init(viewSynchronizer: GridTaskViewSynchronizer, taskID: String, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		super.init(viewSynchronizer: viewSynchronizer, taskID: taskID, eventQuery: eventQuery, storeManager: storeManager)
	}

	public init(task: OCKAnyTask, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		super.init(viewSynchronizer: .init(), task: task, eventQuery: eventQuery, storeManager: storeManager)
	}

	public init(taskID: String, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		super.init(viewSynchronizer: .init(), taskID: taskID, eventQuery: eventQuery, storeManager: storeManager)
	}

	// MARK: - Methods

	override open func viewDidLoad() {
		super.viewDidLoad()
		taskView.collectionView.dataSource = self
	}

	open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		controller.taskEvents.first?.count ?? 0
	}

	open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OCKGridTaskView.defaultCellIdentifier, for: indexPath)
		guard let typedCell = cell as? OCKGridTaskView.DefaultCellType else { return cell }
		let event = controller.taskEvents[indexPath.section][indexPath.row]
		typedCell.update(event: event, animated: false)
		return cell
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "GridTaskView"])
	}

	override open func didSelectTaskView(_ taskView: UIView & OCKTaskDisplayable, eventIndexPath: IndexPath) {}
}

extension OCKGridTaskCell {
	func update(event: OCKAnyEvent?, animated: Bool) {
		guard let event = event else {
			prepareForReuse()
			return
		}

		let isComplete = event.outcome != nil
		let title = isComplete ?
			ScheduleUtility.completedTimeLabel(for: event) :
			ScheduleUtility.timeLabel(for: event, includesEnd: false)

		completionButton.label.text = title
		completionButton.isSelected = isComplete
		accessibilityLabel = title
		accessibilityValue = loc(isComplete ? "COMPLETED" : "INCOMPLETE")
	}
}
