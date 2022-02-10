//
//  FileLoggingViewController.swift
//  Allie
//
//  Created by Waqar Malik on 10/12/21.
//

import CodexFoundation
import MessageUI
import UIKit

class FileLoggingViewController: UIViewController {
	@Injected(\.remoteConfig) var remoteConfig: RemoteConfigManager

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor.allieWhite
		[messageLabel, toggleFileLoggingLabel, toggleSwitch, sendButton].forEach { newView in
			newView.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(newView)
		}

		NSLayoutConstraint.activate([messageLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 5.0),
		                             messageLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: messageLabel.trailingAnchor, multiplier: 2.0)])

		NSLayoutConstraint.activate([toggleFileLoggingLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             toggleFileLoggingLabel.topAnchor.constraint(equalToSystemSpacingBelow: messageLabel.bottomAnchor, multiplier: 5.0),
		                             toggleSwitch.leadingAnchor.constraint(equalToSystemSpacingAfter: toggleFileLoggingLabel.trailingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: toggleSwitch.trailingAnchor, multiplier: 2.0),
		                             toggleSwitch.centerYAnchor.constraint(equalTo: toggleFileLoggingLabel.centerYAnchor)])

		NSLayoutConstraint.activate([sendButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 4.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: sendButton.trailingAnchor, multiplier: 4.0),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: sendButton.bottomAnchor, multiplier: 2.0),
		                             sendButton.heightAnchor.constraint(equalToConstant: 48.0)])
		toggleSwitch.isOn = LoggingManager.isFileLogginEnabled
		toggleSwitch.addTarget(self, action: #selector(toggleLoggin(_:)), for: .valueChanged)
		sendButton.addTarget(self, action: #selector(sendLogs(_:)), for: .touchUpInside)
	}

	let messageLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textColor = .allieGray
		label.textAlignment = .center
		label.font = UIFont.preferredFont(forTextStyle: .body)
		label.numberOfLines = 0
		label.text = "You can enable file logging to be sent to Codex Health for analysis for issue you might be having."
		return label
	}()

	var toggleFileLoggingLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
		label.text = "Toggle File Logging"
		label.textColor = UIColor.allieBlack
		return label
	}()

	let toggleSwitch: UISwitch = {
		let button = UISwitch(frame: .zero)
		button.tintColor = .allieRed
		return button
	}()

	let sendButton: BottomButton = {
		let button = BottomButton(frame: .zero)
		button.setTitle("Send Logs", for: .normal)
		button.setupButton()
		button.setShadow()
		return button
	}()

	@IBAction func toggleLoggin(_ sender: Any?) {
		LoggingManager.isFileLogginEnabled.toggle()
	}

	@IBAction func sendLogs(_ sender: Any?) {
		guard let url = LoggingManager.fileLogURL, let data = try? Data(contentsOf: url, options: .mappedIfSafe) else {
			return
		}
		let mailComposer = MFMailComposeViewController()
		mailComposer.mailComposeDelegate = self
		mailComposer.setToRecipients(["support@codexhealth.com"])
		mailComposer.setSubject("Allie Logs")
		mailComposer.setMessageBody("Attched Logs", isHTML: false)
		mailComposer.addAttachmentData(data, mimeType: "text/plain", fileName: "Allie.log")
		navigationController?.show(mailComposer, sender: self)
	}
}

extension FileLoggingViewController: MFMailComposeViewControllerDelegate {
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true, completion: nil)
		if error == nil {
			if let fileURL = LoggingManager.fileLogURL {
				try? Data().write(to: fileURL, options: .noFileProtection)
			}
		}
	}
}
