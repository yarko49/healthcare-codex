//
//  MyDevicesVC.swift
//  alfred-ios
//

import Foundation
import UIKit
import HealthKit

class MyDevicesVC: BaseVC {
    
    //MARK: Coordinator Actions
    var backBtnAction: (()->())?
    var profileRequestAction: (()->())?
    
    // MARK: - Properties
    
    var devicesSettings: [DevicesSettings] = DevicesSettings.allValues
    let rowHeight: CGFloat = 60
    
    // MARK: - IBOutlets
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var nextBtn: BottomButton!
    @IBOutlet weak var devicesSettingsTV: UITableView!
    
    // MARK: - Setup
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func setupView() {
        super.setupView()
        
        title = Str.myDevices
        let backBtn = UIBarButtonItem(image: UIImage(named: "back")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(backBtnTapped))
        backBtn.tintColor = .black
        self.navigationItem.leftBarButtonItem = backBtn
        bottomView.backgroundColor = UIColor.grey
        nextBtn.backgroundColor = UIColor.next
        nextBtn.setAttributedTitle(Str.next.uppercased().with(style: .regular17, andColor: .white, andLetterSpacing: 5), for: .normal)
        nextBtn.refreshCorners(value: 0)
        nextBtn.setupButton()
        setupTableView()
    }
    
    func setupTableView() {
        devicesSettingsTV.register(UINib(nibName: "SettingsSwitchCell", bundle: nil), forCellReuseIdentifier: "SettingsSwitchCell")
        devicesSettingsTV.rowHeight = rowHeight
        devicesSettingsTV.dataSource = self
        devicesSettingsTV.delegate = self
        devicesSettingsTV.isScrollEnabled = true
        devicesSettingsTV.layoutMargins = UIEdgeInsets.zero
        devicesSettingsTV.separatorInset = UIEdgeInsets.zero
        devicesSettingsTV.tableFooterView = UIView()
        devicesSettingsTV.separatorStyle = .singleLine
        devicesSettingsTV.allowsSelection = false
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func populateData() {
        super.populateData()
    }
    
    //MARK: - Actions
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        profileRequestAction?()
    }
    
    @objc func allowDevices(){
        
    }
    
    @objc func backBtnTapped() {
        backBtnAction?()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension MyDevicesVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devicesSettings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsSwitchCell", for: indexPath) as! SettingsSwitchCell
        cell.layoutMargins = UIEdgeInsets.zero
        
        cell.setup(type: devicesSettings[indexPath.row])
        return cell
    }
}
