//
//  NewDailyTasksPageViewController.swift
//  Allie
//
//  Created by Onseen on 1/25/22.
//

import UIKit

class NewDailyTasksPageViewController: BaseViewController {

    @Injected(\.careManager) var careManager: CareManager
    @Injected(\.healthKitManager) var healthKitManager: HealthKitManager
    @Injected(\.networkAPI) var networkAPI: AllieAPI
    @Injected(\.bluetoothManager) var bloodGlucoseMonitor: BGMBluetoothManager
    @Injected(\.remoteConfig) var remoteConfig: RemoteConfigManager

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        datePicker.setValue(UIColor.white, forKey: "backgroundColor")
        return datePicker
    }()

    private var topView: DailyTaskTopView = {
        let topView = DailyTaskTopView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.setShadow()
        return topView
    }()

    private var collectionView: UICollectionView = {
        let size = NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
                                          heightDimension: NSCollectionLayoutDimension.estimated(44))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        section.interGroupSpacing = 0
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .absolute(0))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize,
                                                                        elementKind: "SectionHeaderElementKind",
                                                                        alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]
        let layout = UICollectionViewCompositionalLayout(section: section)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(RiseSleepCell.self, forCellWithReuseIdentifier: RiseSleepCell.cellID)
        collectionView.register(HealthCell.self, forCellWithReuseIdentifier: HealthCell.cellID)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        view.addSubview(topView)
        topView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor).isActive = true
        topView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        topView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        topView.delegate = self
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(datePicker)
        datePicker.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        datePicker.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        datePicker.isHidden = true
        datePicker.addTarget(self, action: #selector(onChangeDate), for: .valueChanged)
    }

    @objc func onChangeDate(sender: UIDatePicker) {
        datePicker.isHidden = true
    }
}

 // MARK: - Collection View Delegate & Data Source
extension NewDailyTasksPageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RiseSleepCell.cellID, for: indexPath) as! RiseSleepCell
            cell.cellType = .rise
            return cell
        } else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthCell.cellID, for: indexPath) as! HealthCell
            cell.configureCell(cellType: .glucose, index: 1, isEmpty: false)
            return cell
        } else if indexPath.row == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthCell.cellID, for: indexPath) as! HealthCell
            cell.configureCell(cellType: .insulin, index: 2, isEmpty: false)
            return cell
        } else if indexPath.row == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthCell.cellID, for: indexPath) as! HealthCell
            cell.configureCell(cellType: .glucose, index: 3, isEmpty: true)
            return cell
        } else if indexPath.row == 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthCell.cellID, for: indexPath) as! HealthCell
            cell.configureCell(cellType: .insulin, index: 4, isEmpty: true)
            return cell
        } else if indexPath.row == 5 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthCell.cellID, for: indexPath) as! HealthCell
            cell.configureCell(cellType: .add, index: 5, isEmpty: false)
            return cell
        } else if indexPath.row == 6 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthCell.cellID, for: indexPath) as! HealthCell
            cell.configureCell(cellType: .aspirin, index: 6, isEmpty: false)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RiseSleepCell.cellID, for: indexPath) as! RiseSleepCell
            cell.cellType = .sleep
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
}

 // MARK: - Top View Delegate
extension NewDailyTasksPageViewController: DailyTaskTopViewDelegate {
    func onClickTodayButton() {
        UIView.animate(withDuration: 0.3) {
            self.datePicker.isHidden = false
        }
    }
}
