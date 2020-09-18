//
//  SettingsSwitchCell.swift
//  alfred-ios
//

import UIKit

class SettingsSwitchCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var settingsSwitch: UISwitch!
    
    var devicesType = DevicesSettings.none
    var notificationsType = MyNotifications.none
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func setup(type: DevicesSettings) {
        self.devicesType = type
        
        settingsSwitch.isOn = initializeDevicesSwitch()
        descriptionLbl.attributedText = self.devicesType.description.with(style: .regular17, andColor: UIColor.grey, andLetterSpacing: -0.41)
    }
    
    func setup(type: MyNotifications) {
        self.notificationsType = type
        
        settingsSwitch.isOn = initializeNotificationsSwitch()
        descriptionLbl.attributedText = self.notificationsType.description.with(style: .regular17, andColor: UIColor.grey, andLetterSpacing: -0.41)
    }
    
    private func initializeDevicesSwitch() -> Bool{
        switch self.devicesType {
        case .smartScale:
            return DataContext.shared.hasSmartScale
        case .smartBlockPressureCuff:
            return DataContext.shared.hasSmartBlockPressureCuff
        case .smartWatch:
            return DataContext.shared.hasSmartWatch
        case .smartPedometer:
            return DataContext.shared.hasSmartPedometer
        default:
            return false
        }
    }
    
    private func initializeNotificationsSwitch() -> Bool{
        switch self.notificationsType {
        case .activityPushNotifications:
            return DataContext.shared.activityPushNotificationsIsOn
        case .bloodPressurePushNotifications:
            return DataContext.shared.bloodPressurePushNotificationsIsOn
        case .weightInPushNotifications:
            return DataContext.shared.weightInPushNotificationsIsOn
        case .surveyPushNotifications:
            return DataContext.shared.surveyPushNotificationsIsOn
        default:
            return false
        }
    }
    
    @IBAction func switchValueChanged(_ sender: Any) {
        switch self.devicesType {
        case .smartScale:
            DataContext.shared.hasSmartScale.toggle()
        case .smartBlockPressureCuff:
            DataContext.shared.hasSmartBlockPressureCuff.toggle()
        case .smartWatch:
            DataContext.shared.hasSmartWatch.toggle()
        case .smartPedometer:
            DataContext.shared.hasSmartPedometer.toggle()
        default:
            break
        }
        
        switch self.notificationsType {
        case .activityPushNotifications:
            DataContext.shared.activityPushNotificationsIsOn.toggle()
        case .bloodPressurePushNotifications:
            DataContext.shared.bloodPressurePushNotificationsIsOn.toggle()
        case .weightInPushNotifications:
            DataContext.shared.weightInPushNotificationsIsOn.toggle()
        case .surveyPushNotifications:
            DataContext.shared.surveyPushNotificationsIsOn.toggle()
        default:
            break
        }
    }
}
