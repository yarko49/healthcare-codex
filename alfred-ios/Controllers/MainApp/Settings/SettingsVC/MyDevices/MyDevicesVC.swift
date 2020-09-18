//
//  MyDevicesVC.swift
//  alfred-ios
//

import Foundation
import UIKit

class MyDevicesVC: BaseVC {
    
    //MARK: Coordinator Actions
    var backBtnAction: (()->())?
    
    // MARK: - Properties
    
    var devicesSettings: [DevicesSettings] = DevicesSettings.allValues
    let rowHeight: CGFloat = 60
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var devicesSettingsTV: UITableView!
    
    // MARK: - Setup

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backBtn = UIBarButtonItem(image: UIImage(named: "back")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(backBtnTapped))
        backBtn.tintColor = .black
        
        self.navigationItem.leftBarButtonItem = backBtn
    }
    
    override func setupView() {
        super.setupView()
        
        title = Str.myDevices
        
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
