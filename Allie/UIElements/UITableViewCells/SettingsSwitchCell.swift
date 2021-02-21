//
//  SettingsSwitchCell.swift
//  Allie
//

import UIKit

class SettingsSwitchCell: UITableViewCell {
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var settingsSwitch: UISwitch!

	var smartDeviceType: SmartDeviceType?
	var notificationsType: NotificationType?

	override func awakeFromNib() {
		super.awakeFromNib()
		selectionStyle = .none
	}

	func setup(type: SmartDeviceType) {
		smartDeviceType = type
		settingsSwitch.isOn = hasSmartDevice
		descriptionLabel.attributedText = smartDeviceType?.title.with(style: .regular17, andColor: UIColor.grey, andLetterSpacing: -0.41)
	}

	func setup(type: NotificationType) {
		notificationsType = type

		settingsSwitch.isOn = isNotificationEnabled
		descriptionLabel.attributedText = notificationsType?.title.with(style: .regular17, andColor: UIColor.grey, andLetterSpacing: -0.41)
	}

	private var hasSmartDevice: Bool {
		guard let deviceType = smartDeviceType else {
			return false
		}
		return DataContext.shared.hasSmartDevice(type: deviceType)
	}

	private var isNotificationEnabled: Bool {
		guard let notificationType = notificationsType else {
			return false
		}
		switch notificationType {
		case .activity:
			return DataContext.shared.activityPushNotificationsIsOn
		case .bloodPressure:
			return DataContext.shared.bloodPressurePushNotificationsIsOn
		case .weightIn:
			return DataContext.shared.weightInPushNotificationsIsOn
		case .survey:
			return DataContext.shared.surveyPushNotificationsIsOn
		}
	}

	@IBAction func switchValueChanged(_ sender: Any) {
		switch smartDeviceType {
		case .scale:
			DataContext.shared.hasSmartScale.toggle()
		case .bloodPressureCuff:
			DataContext.shared.hasSmartBloodPressureCuff.toggle()
		case .watch:
			DataContext.shared.hasSmartWatch.toggle()
		case .pedometer:
			DataContext.shared.hasSmartPedometer.toggle()
		default:
			break
		}

		switch notificationsType {
		case .activity:
			DataContext.shared.activityPushNotificationsIsOn.toggle()
		case .bloodPressure:
			DataContext.shared.bloodPressurePushNotificationsIsOn.toggle()
		case .weightIn:
			DataContext.shared.weightInPushNotificationsIsOn.toggle()
		case .survey:
			DataContext.shared.surveyPushNotificationsIsOn.toggle()
		default:
			break
		}
	}
}
