//
//  NewDailyTasksPageViewController+.swift
//  Allie
//
//  Created Onseen on 2/12/22.
//

import AscensiaKit
import UIKit
import JGProgressHUD
import Combine
import CareKitStore
import CareKit
import SwiftUI
import BluetoothService
import CodexFoundation

// MARK: - Collection View Delegate & Data Source
extension NewDailyTasksPageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       // swiftlint:disable force_cast
       if indexPath.row == 0 {
           let cell = collectionView.dequeueReusableCell(
               withReuseIdentifier: RiseSleepCell.cellID, for: indexPath) as! RiseSleepCell
           cell.cellType = .rise
           return cell
       } else if indexPath.row == viewModel.timelineItemViewModels.count + 2 {
           let cell = collectionView.dequeueReusableCell(
               withReuseIdentifier: RiseSleepCell.cellID, for: indexPath) as! RiseSleepCell
           cell.cellType = .sleep
           return cell
       } else if indexPath.row == viewModel.timelineItemViewModels.count + 3 {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthLastCell.cellID, for: indexPath) as! HealthLastCell
           return cell
       } else {
           if let addIndex = addCellIndex {
               if indexPath.row - 1 == addIndex {
                   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthAddCell.cellID, for: indexPath) as! HealthAddCell
                   return cell
               } else {
                   let index = indexPath.row - 1 < addIndex ? indexPath.row - 1 : indexPath.row - 2
                   let timelineViewModel = viewModel.timelineItemViewModels[index]
                   let taskType = timelineViewModel.timelineItemModel.event.task.groupIdentifierType
                   if taskType == .link {
                       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LinkCell.cellID, for: indexPath) as! LinkCell
                       cell.configureCell(timelineItemViewModel: timelineViewModel)
                       return cell
                   } else if taskType == .featuredContent {
                       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedCell.cellID, for: indexPath) as! FeaturedCell
                       cell.configureCell(timelineItemViewModel: timelineViewModel)
                       return cell
                   } else if taskType == .numericProgress {
                       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NumericProgressCell.cellID, for: indexPath) as! NumericProgressCell
                       cell.configureCell(timelineItemViewModel: timelineViewModel)
                       return cell
                   } else {
                       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthCell.cellID, for: indexPath) as! HealthCell
                       cell.configureCell(item: timelineViewModel, cellIndex: index)
                       cell.delegate = self
                       return cell
                   }
               }
           } else {
               if indexPath.row == viewModel.timelineItemViewModels.count + 1 {
                   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthAddCell.cellID, for: indexPath) as! HealthAddCell
                   return cell
               } else {
                   let index = indexPath.row - 1
                   let timelineViewModel = viewModel.timelineItemViewModels[index]
                   let taskType = timelineViewModel.timelineItemModel.event.task.groupIdentifierType
                   if taskType == .link {
                       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LinkCell.cellID, for: indexPath) as! LinkCell
                       cell.configureCell(timelineItemViewModel: timelineViewModel)
                       return cell
                   } else if taskType == .featuredContent {
                       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedCell.cellID, for: indexPath) as! FeaturedCell
                       cell.configureCell(timelineItemViewModel: timelineViewModel)
                       return cell
                   } else if taskType == .numericProgress {
                       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NumericProgressCell.cellID, for: indexPath) as! NumericProgressCell
                       cell.configureCell(timelineItemViewModel: timelineViewModel)
                       return cell
                   } else {
                       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthCell.cellID, for: indexPath) as! HealthCell
                       cell.configureCell(item: timelineViewModel, cellIndex: index)
                       cell.delegate = self
                       return cell
                   }
               }
           }
       }
       // swiftlint:enable force_cast
   }

   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return viewModel.timelineItemViewModels.count + 4
   }
}
// MARK: - Collection Cell Delegate

extension NewDailyTasksPageViewController: HealthCellDelegate {
    func onCellClickForActive(cellIndex: Int) {
        let timelineViewModels = viewModel.timelineItemViewModels
        for taskIndex in 0..<timelineViewModels.count {
            let timelineItem = timelineViewModels[taskIndex]
            if timelineItem.cellType == .current {
                continue
            } else {
                timelineItem.tapCount = 0
            }
        }
        timelineViewModels[cellIndex].tapCount = 1
        viewModel.timelineItemViewModels = timelineViewModels
    }

    func onAddTaskData(timelineViewModel: TimelineItemViewModel) {
        let groupIdentifierType = timelineViewModel.timelineItemModel.event.task.groupIdentifierType
        if groupIdentifierType == .symptoms || groupIdentifierType == .labeledValue {
            let viewController = GeneralizedLogTaskDetailViewController()
            viewController.queryDate = OCKEventQuery(for: selectedDate).dateInterval.start
            viewController.outcomeValues = []
            if groupIdentifierType == .symptoms {
                guard let task = timelineViewModel.timelineItemModel.event.task as? OCKTask else {
                    return
                }
                viewController.anyTask = task
                viewController.outcomeIndex = 0
            } else {
                guard let task = timelineViewModel.timelineItemModel.event.task as? OCKHealthKitTask else {
                    return
                }
                viewController.anyTask = task
                viewController.outcome = nil
            }
            viewController.modalPresentationStyle = .overFullScreen
            viewController.cancelAction = { [weak viewController] in
                viewController?.dismiss(animated: true, completion: nil)
            }
            if groupIdentifierType == .symptoms {
                viewController.outcomeValueHandler = { [weak viewController, weak self] newOutcomeValue in
                    guard let strongSelf = self, let task = viewController?.anyTask as? OCKTask, let carePlanId = task.carePlanId else {
                        return
                    }
                    strongSelf.viewModel.addOutcomeValue(newValue: newOutcomeValue, carePlanId: carePlanId, task: task, event: timelineViewModel.timelineItemModel.event) { result in
                        switch result {
                        case .failure(let error):
                            ALog.error("Error appnding outcome", error: error)
                        case .success(let outcome):
                            ALog.info("Did append value \(outcome.uuid)")
                            strongSelf.viewModel.loadHealthData(date: strongSelf.selectedDate)
                        }
                        DispatchQueue.main.async {
                            viewController?.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            } else {
                viewController.healthKitSampleHandler = { [weak viewController, weak self] newSample in
                    guard let strongSelf = self, let task = (viewController?.anyTask as? OCKHealthKitTask) else {
                        return
                    }
                    strongSelf.viewModel.addOutcome(newValue: newSample, task: task) { result in
                        switch result {
                        case .failure(let error):
                            ALog.error("unable to upload outcome", error: error)
                        case .success:
                            strongSelf.viewModel.loadHealthData(date: strongSelf.selectedDate)
                        }
                        DispatchQueue.main.async {
                            viewController?.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
            tabBarController?.showDetailViewController(viewController, sender: self)
        } else {
            return
        }
    }

    func onUpdateTaskData(timelineViewModel: TimelineItemViewModel) {
        let groupIdentifierType = timelineViewModel.timelineItemModel.event.task.groupIdentifierType
        if groupIdentifierType == .symptoms || groupIdentifierType == .labeledValue {
            let viewController = GeneralizedLogTaskDetailViewController()
            viewController.queryDate = OCKEventQuery(for: selectedDate).dateInterval.start
            viewController.outcomeValues = timelineViewModel.timelineItemModel.outcomeValues ?? []
            if groupIdentifierType == .symptoms {
                guard let task = timelineViewModel.timelineItemModel.event.task as? OCKTask else {
                    return
                }
                viewController.anyTask = task
                viewController.outcomeIndex = 0
            } else {
                guard let task = timelineViewModel.timelineItemModel.event.task as? OCKHealthKitTask else {
                    return
                }
                viewController.anyTask = task
                let value = timelineViewModel.timelineItemModel.outcomeValues?.first
                if let uuid = value?.healthKitUUID {
                    viewController.outcome = try? careManager.dbFindFirstOutcome(uuid: uuid)
                }
            }
            viewController.modalPresentationStyle = .overFullScreen
            viewController.cancelAction = { [weak viewController] in
                viewController?.dismiss(animated: true, completion: nil)
            }
            if groupIdentifierType == .symptoms {
                viewController.outcomeValueHandler = { [weak viewController, weak self] newOutcomeValue in
                    guard let strongSelf = self, let task = (viewController?.anyTask as? OCKTask) else {
                        return
                    }
                    guard let index = viewController?.outcomeIndex, let outcome = timelineViewModel.timelineItemModel.event.outcome as? OCKOutcome, index < outcome.values.count else {
                        return
                    }
                    strongSelf.viewModel.updateOutcomeValue(newValue: newOutcomeValue, for: outcome, event: timelineViewModel.timelineItemModel.event, at: index, task: task) { result in
                        switch result {
                        case .success:
                            strongSelf.viewModel.loadHealthData(date: strongSelf.selectedDate)
                        case .failure(let error):
                            ALog.error("failed updating", error: error)
                        }
                        viewController?.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                viewController.healthKitSampleHandler = { [weak viewController, weak self] newSample in
                    guard let strongSelf = self, let outcomeValue = viewController?.outcomeValues.first, let task = (viewController?.anyTask as? OCKHealthKitTask) else {
                        return
                    }
                    strongSelf.viewModel.updateOutcome(newSample: newSample, outcomeValue: outcomeValue, task: task) { result in
                        switch result {
                        case .success:
                            strongSelf.viewModel.loadHealthData(date: strongSelf.selectedDate)
                        case .failure(let error):
                            ALog.error("Error updateing data", error: error)
                        }
                        viewController?.dismiss(animated: true, completion: nil)
                    }
                }
            }
            viewController.deleteAction = { [weak self, weak viewController] in
                if groupIdentifierType == .symptoms {
                    guard let strongSelf = self, let index = viewController?.outcomeIndex, let task = viewController?.task else {
                        viewController?.dismiss(animated: true, completion: nil)
                        return
                    }
                    do {
                        guard let eventOutcome = timelineViewModel.timelineItemModel.event.outcome as? OCKOutcome, index < eventOutcome.values.count else {
                            throw AllieError.missing("No Outcome Value for Event at index\(index)")
                        }
                        strongSelf.viewModel.deleteOutcomeValue(at: index, for: eventOutcome, task: task) { result in
                            switch result {
                            case .success(let deletedOutcome):
                                ALog.trace("Uploaded the outcome \(deletedOutcome.remoteId ?? "")")
                                self?.viewModel.loadHealthData(date: self?.selectedDate ?? Date())
                            case .failure(let error):
                                ALog.error("unable to upload outcome", error: error)
                            }
                            DispatchQueue.main.async {
                                viewController?.dismiss(animated: true, completion: nil)
                            }
                        }
                    } catch {
                        ALog.error("Can not delete outcome", error: error)
                        DispatchQueue.main.async {
                            viewController?.dismiss(animated: true, completion: nil)
                        }
                    }
                } else {
                    guard let outcomeValue = viewController?.outcomeValues.first, let task = viewController?.healthKitTask else {
                        viewController?.dismiss(animated: true, completion: nil)
                        return
                    }
                    self?.viewModel.deleteOutcom(value: outcomeValue, task: task, completion: { result in
                        switch result {
                        case .success(let sample):
                            self?.viewModel.loadHealthData(date: self?.selectedDate ?? Date())
                            ALog.trace("\(sample.uuid) sample was deleted", metadata: nil)
                        case .failure(let error):
                            ALog.error("Error deleting data", error: error)
                        }
                        DispatchQueue.main.async {
                            viewController?.dismiss(animated: true, completion: nil)
                        }
                    })
                }
            }
            tabBarController?.showDetailViewController(viewController, sender: self)
        } else {
            return
        }
    }

    func onCheckTaskData(timelineViewModel: TimelineItemViewModel) {
        let isComplete = timelineViewModel.cellType == .completed
        viewModel.setCheckTask(ockEvent: timelineViewModel.timelineItemModel.event, isComplete: !isComplete) { [weak self] result in
            switch result {
            case .success:
                self?.viewModel.loadHealthData(date: self!.selectedDate)
            case .failure(let error):
                ALog.error("unable to upload outcome", error: error)
            }
        }
    }
}
