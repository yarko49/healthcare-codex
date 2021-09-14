//
//  BGMDeviceDetailViewController.swift
//  Allie
//
//  Created by Waqar Malik on 8/24/21.
//

import UIKit

class BGMDeviceDetailViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .allieWhite
		title = NSLocalizedString("DEVICE_DETAIL", comment: "Device Detail")
		commonInit()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		configureView()
	}

	@Injected(\.bluetoothManager) var bluetoothManager: BGMBluetoothManager
	@Injected(\.careManager) var careManager: CareManager

	var device: String? {
		didSet {
			configureView()
		}
	}

	let titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textColor = .allieGray
		label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
		return label
	}()

	let imageView: UIImageView = {
		let view = UIImageView(frame: .zero)
		view.image = UIImage(systemName: "circlebadge.fill")
		view.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
		view.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
		view.contentMode = .scaleAspectFit
		return view
	}()

	let subtitleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textColor = .allieGray
		label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
		return label
	}()

	private let labelStackView: UIStackView = {
		let view = UIStackView(frame: .zero)
		view.axis = .vertical
		view.spacing = 8.0
		view.distribution = .fill
		view.alignment = .fill
		return view
	}()

	private let stackView: UIStackView = {
		let view = UIStackView(frame: .zero)
		view.axis = .horizontal
		view.spacing = 8.0
		view.distribution = .fill
		view.alignment = .fill
		return view
	}()

	let unpairButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitleColor(.allieRed, for: .normal)
		button.backgroundColor = .allieWhite
		button.layer.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
		button.layer.borderWidth = 1.0
		button.layer.borderColor = UIColor.allieRed.cgColor
		button.setTitle(NSLocalizedString("UNPAIR", comment: "Unpair"), for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
		button.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
		button.setShadow()
		return button
	}()

	private func configureView() {
		guard let device = self.device else {
			return
		}
		title = device
		titleLabel.text = device
		subtitleLabel.text = nil
	}

	private func commonInit() {
		[titleLabel, subtitleLabel, imageView, labelStackView, stackView, unpairButton].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}

		labelStackView.addArrangedSubview(titleLabel)
		labelStackView.addArrangedSubview(subtitleLabel)
		stackView.addArrangedSubview(labelStackView)
		stackView.addArrangedSubview(imageView)
		view.addSubview(stackView)
		NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 15.0),
		                             stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 3.0)])

		view.addSubview(unpairButton)
		NSLayoutConstraint.activate([unpairButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: unpairButton.trailingAnchor, multiplier: 3.0),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: unpairButton.bottomAnchor, multiplier: 2.0)])
		unpairButton.addTarget(self, action: #selector(showUnpairAlert(_:)), for: .touchUpInside)
	}

	@IBAction func showUnpairAlert(_ sender: Any?) {
		let title = NSLocalizedString("UNPAIR_DEVICE", comment: "Would you like to unpair this device?")
		let message = NSLocalizedString("UNPAIR_DEVICE.message", comment: "Your device will be disconnected and will not stream data into your Allie account.")
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .cancel, handler: nil)
		alertController.addAction(cancelAction)
		let unpairAction = UIAlertAction(title: NSLocalizedString("UNPAIR", comment: "Unpair"), style: .destructive) { [weak self] _ in
			self?.bluetoothManager.stopMonitoring()
			if var patient = self?.careManager.patient {
				patient.bgmIdentifier = nil
				patient.bgmLastSync = nil
				patient.bgmLastSyncDate = nil
				patient.bgmName = nil
				self?.careManager.patient = patient
				self?.careManager.upload(patient: patient)
			}
			self?.navigationController?.popViewController(animated: true)
		}
		alertController.addAction(unpairAction)
		(tabBarController ?? navigationController ?? self).showDetailViewController(alertController, sender: self)
	}
}
