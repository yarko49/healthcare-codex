//
//  DailyTaskTopView.swift
//  Allie
//
//  Created by Onseen on 1/25/22.
//

import CareKit
import CareModel
import CodexFoundation
import UIKit

protocol DailyTaskTopViewDelegate: AnyObject {
	func onClickTodayButton()
	func onClickNotGreat()
	func onClickDateSelectionButton(date: Date)
}

class DailyTaskTopView: UIView {
	@Injected(\.careManager) var careManager: CareManager

	weak var delegate: DailyTaskTopViewDelegate?
	private var selectedDate: Date = .init()

	private var wholeStackView: UIStackView = {
		let wholeStackView = UIStackView()
		wholeStackView.translatesAutoresizingMaskIntoConstraints = false
		wholeStackView.axis = .vertical
		wholeStackView.alignment = .center
		wholeStackView.distribution = .fill
		wholeStackView.spacing = 0
		return wholeStackView
	}()

	private var greetingView: UIView = {
		let greetingView = UIView()
		greetingView.translatesAutoresizingMaskIntoConstraints = false
		greetingView.backgroundColor = .white
		greetingView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
		greetingView.layer.cornerRadius = 10.0
		greetingView.setShadow()
		return greetingView
	}()

	private var greetingStackView: UIStackView = {
		let greetingStackView = UIStackView()
		greetingStackView.translatesAutoresizingMaskIntoConstraints = false
		greetingStackView.axis = .vertical
		greetingStackView.alignment = .center
		greetingStackView.distribution = .fill
		greetingStackView.spacing = 20.0
		return greetingStackView
	}()

	private var greetingImage: UIImageView = {
		let greetingImage = UIImageView()
		greetingImage.translatesAutoresizingMaskIntoConstraints = false
		greetingImage.contentMode = .scaleAspectFit
		return greetingImage
	}()

	private var greetingLabel: UILabel = {
		let greetingLabel = UILabel()
		greetingLabel.translatesAutoresizingMaskIntoConstraints = false
		greetingLabel.numberOfLines = 0
		greetingLabel.textAlignment = .center
		return greetingLabel
	}()

	private let helloLabel: UILabel = {
		let helloLabel = UILabel()
		helloLabel.translatesAutoresizingMaskIntoConstraints = false
		helloLabel.numberOfLines = 0
		helloLabel.textAlignment = .center
		return helloLabel
	}()

	private var calendarView: UIView = {
		let calendarView = UIView()
		calendarView.backgroundColor = .white
		calendarView.setShadow()
		calendarView.translatesAutoresizingMaskIntoConstraints = false
		return calendarView
	}()

	private var todayButton: UIButton = {
		let todayButton = UIButton()
		todayButton.translatesAutoresizingMaskIntoConstraints = false
		todayButton.setAttributedTitle("Today".attributedString(style: .silkabold20, foregroundColor: .black), for: .normal)
		return todayButton
	}()

	private var beforeButton: UIButton = {
		let beforeButton = UIButton()
		beforeButton.translatesAutoresizingMaskIntoConstraints = false
		beforeButton.backgroundColor = .clear
		beforeButton.setTitle(nil, for: .normal)
		beforeButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
		beforeButton.tintColor = .black
		beforeButton.tag = 0
		return beforeButton
	}()

	private var nextButton: UIButton = {
		let nextButton = UIButton()
		nextButton.translatesAutoresizingMaskIntoConstraints = false
		nextButton.backgroundColor = .clear
		nextButton.setTitle(nil, for: .normal)
		nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
		nextButton.tintColor = .black
		nextButton.tag = 1
		return nextButton
	}()

	override init(frame: CGRect) {
		super.init(frame: .zero)
		setupViews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupViews() {
		backgroundColor = .white
		wholeStackView.addArrangedSubview(greetingView)
		NSLayoutConstraint.activate([greetingView.leadingAnchor.constraint(equalTo: wholeStackView.leadingAnchor, constant: 10),
		                             wholeStackView.trailingAnchor.constraint(equalTo: greetingView.trailingAnchor, constant: 10)])
		greetingView.addSubview(greetingStackView)
		NSLayoutConstraint.activate([greetingStackView.centerXAnchor.constraint(equalTo: greetingView.centerXAnchor),
		                             greetingStackView.leadingAnchor.constraint(equalTo: greetingView.leadingAnchor),
		                             greetingStackView.topAnchor.constraint(equalTo: greetingView.topAnchor, constant: 30),
		                             greetingStackView.bottomAnchor.constraint(equalTo: greetingView.bottomAnchor, constant: -30)])

		[greetingImage, greetingLabel, helloLabel].forEach { greetingStackView.addArrangedSubview($0) }

		NSLayoutConstraint.activate([greetingImage.widthAnchor.constraint(equalToConstant: 100),
		                             greetingImage.heightAnchor.constraint(equalToConstant: 100)])

		var greetingPatient = ""
		if let patientName = careManager.patient?.displayName {
			greetingPatient = "\(patientName)!"
		}

		let dateState = getDateState()

		greetingLabel.attributedText = "\(dateState.greetings) \(greetingPatient)".attributedString(style: .silkabold20, foregroundColor: .mainGray)
		helloLabel.attributedText = dateState.description.attributedString(style: .silkaregular17, foregroundColor: .allieLightGray)
		greetingImage.image = UIImage(named: dateState.iconName)

		wholeStackView.addArrangedSubview(calendarView)
		calendarView.widthAnchor.constraint(equalTo: wholeStackView.widthAnchor).isActive = true
		calendarView.heightAnchor.constraint(equalToConstant: 60).isActive = true
		calendarView.addSubview(todayButton)
		todayButton.centerXAnchor.constraint(equalTo: calendarView.centerXAnchor).isActive = true
		todayButton.centerYAnchor.constraint(equalTo: calendarView.centerYAnchor).isActive = true
		todayButton.addTarget(self, action: #selector(onClickTodayButton), for: .touchUpInside)

		calendarView.addSubview(beforeButton)
		beforeButton.centerYAnchor.constraint(equalTo: calendarView.centerYAnchor).isActive = true
		beforeButton.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 50).isActive = true

		calendarView.addSubview(nextButton)
		nextButton.centerYAnchor.constraint(equalTo: calendarView.centerYAnchor).isActive = true
		nextButton.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -50).isActive = true

		beforeButton.addTarget(self, action: #selector(onClickDateSelectionButton), for: .touchUpInside)
		nextButton.addTarget(self, action: #selector(onClickDateSelectionButton), for: .touchUpInside)

		addSubview(wholeStackView)
		wholeStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		wholeStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		wholeStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		wholeStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

		calendarView.isHidden = true

		setButtonTitle(date: selectedDate)

		showAnimation()
	}

	func showAnimation() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
			UIView.animate(withDuration: 0.5) {
				self.greetingView.isHidden = true
				self.layoutIfNeeded()
			} completion: { _ in
				UIView.animate(withDuration: 0.5) {
					self.calendarView.isHidden = false
					self.layoutIfNeeded()
				}
			}
		}
	}

	private func getDateState() -> DateStateModel {
		let hour = Calendar.current.component(.hour, from: Date())
		switch hour {
		case 0 ..< 12:
			return DateState.morning.dateState
		case 12 ..< 16:
			return DateState.afternoon.dateState
		case 16 ..< 24:
			return DateState.evening.dateState
		default:
			return DateState.morning.dateState
		}
	}

	@objc func onClickTodayButton() {
		delegate?.onClickTodayButton()
	}

	@objc func onClickDateSelectionButton(sender: UIButton) {
		let calendar = Calendar.current
		let date = calendar.date(byAdding: .day, value: sender.tag == 0 ? -1 : 1, to: selectedDate)!
		setButtonTitle(date: date)
		delegate?.onClickDateSelectionButton(date: selectedDate)
	}

	func setButtonTitle(date: Date) {
		var buttonTitle = ""
		selectedDate = date
		if Calendar.current.isDateInToday(date) {
			nextButton.isHidden = true
			buttonTitle = "Today"
		} else {
			if date > Date() {
				nextButton.isHidden = true
				return
			} else {
				nextButton.isHidden = false
				buttonTitle = DateFormatter.yyyyMMdd.string(from: date)
			}
		}
		todayButton.setAttributedTitle(buttonTitle.attributedString(style: .silkabold20, foregroundColor: .black), for: .normal)
	}
}

enum DateState {
	case morning, afternoon, evening

	var dateState: DateStateModel {
		switch self {
		case .morning:
			return DateStateModel(
				iconName: "img-morning",
				greetings: "Good morning",
				description: "Remember to take\nsome deep breaths"
			)
		case .afternoon:
			return DateStateModel(
				iconName: "img-afternoon",
				greetings: "Good afternoon",
				description: "Drinking two liters of water a day can\nhelp burn fat and increase energy levels"
			)
		case .evening:
			return DateStateModel(
				iconName: "img-evening",
				greetings: "Good evening",
				description: "Getting a proper amount of deep sleep\nis essential to your health"
			)
		}
	}
}

struct DateStateModel {
	let iconName: String
	let greetings: String
	let description: String
}
