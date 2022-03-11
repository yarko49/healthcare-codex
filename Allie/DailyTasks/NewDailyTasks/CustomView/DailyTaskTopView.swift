//
//  DailyTaskTopView.swift
//  Allie
//
//  Created by Onseen on 1/25/22.
//

import UIKit

protocol DailyTaskTopViewDelegate: AnyObject {
	func onClickTodayButton()
	func onClickNotGreat()
}

class DailyTaskTopView: UIView {
	weak var delegate: DailyTaskTopViewDelegate?

	private var wholeStackView: UIStackView = {
		let wholeStackView = UIStackView()
		wholeStackView.translatesAutoresizingMaskIntoConstraints = false
		wholeStackView.axis = .vertical
		wholeStackView.alignment = .top
		return wholeStackView
	}()

	private var greetingView: UIView = {
		let greetingView = UIView()
		greetingView.translatesAutoresizingMaskIntoConstraints = false
		greetingView.backgroundColor = .white
		return greetingView
	}()

	private var greetingLabel: UILabel = {
		let greetingLabel = UILabel()
		greetingLabel.translatesAutoresizingMaskIntoConstraints = false
		greetingLabel.attributedText = "Good morning Susan!".attributedString(style: .silkabold20, foregroundColor: .black)
		return greetingLabel
	}()

	private let helloLabel: UILabel = {
		let helloLabel = UILabel()
		helloLabel.translatesAutoresizingMaskIntoConstraints = false
		helloLabel.attributedText = "How are you\nfeeling today?".attributedString(style: .silkabold24, foregroundColor: .mainBlue)
		helloLabel.numberOfLines = 0
		return helloLabel
	}()

	private var greetingStackView: UIStackView = {
		let greetingStackView = UIStackView()
		greetingStackView.translatesAutoresizingMaskIntoConstraints = false
		greetingStackView.axis = .horizontal
		greetingStackView.distribution = .fillEqually
		greetingStackView.alignment = .fill
		return greetingStackView
	}()

	private var statusView: UIView = {
		let statusView = UIView()
		statusView.translatesAutoresizingMaskIntoConstraints = false
		statusView.backgroundColor = .mainGreen
		return statusView
	}()

	private var statusLabel: UILabel = {
		let statusLabel = UILabel()
		statusLabel.translatesAutoresizingMaskIntoConstraints = false
		statusLabel.font = .systemFont(ofSize: 20, weight: .bold)
		statusLabel.textColor = .mainDarkGreen
		return statusLabel
	}()

	private var calendarView: UIView = {
		let calendarView = UIView()
		calendarView.backgroundColor = .white
		calendarView.translatesAutoresizingMaskIntoConstraints = false
		return calendarView
	}()

	private var todayButton: UIButton = {
		let todayButton = UIButton()
		todayButton.translatesAutoresizingMaskIntoConstraints = false
		todayButton.setAttributedTitle("Today".attributedString(style: .silkabold20, foregroundColor: .black), for: .normal)
		return todayButton
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
		setShadow(shadowRadius: 10.0, opacity: 0.1)
		wholeStackView.addArrangedSubview(greetingView)
		greetingView.addSubview(greetingLabel)
		greetingView.addSubview(helloLabel)
		greetingView.addSubview(greetingStackView)

		greetingLabel.topAnchor.constraint(equalTo: greetingView.topAnchor, constant: 48).isActive = true
		greetingLabel.centerXAnchor.constraint(equalTo: greetingView.centerXAnchor).isActive = true
		greetingLabel.leadingAnchor.constraint(equalTo: greetingView.leadingAnchor, constant: 32).isActive = true

		helloLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 12.0).isActive = true
		helloLabel.leadingAnchor.constraint(equalTo: greetingView.leadingAnchor, constant: 32).isActive = true
		helloLabel.centerXAnchor.constraint(equalTo: greetingView.centerXAnchor).isActive = true

		greetingView.widthAnchor.constraint(equalTo: wholeStackView.widthAnchor).isActive = true

		greetingStackView.centerXAnchor.constraint(equalTo: greetingView.centerXAnchor).isActive = true
		greetingStackView.leadingAnchor.constraint(equalTo: greetingView.leadingAnchor, constant: 32.0).isActive = true
		greetingStackView.topAnchor.constraint(equalTo: helloLabel.bottomAnchor, constant: 24.0).isActive = true
		greetingStackView.bottomAnchor.constraint(equalTo: greetingView.bottomAnchor, constant: -24).isActive = true
		greetingStackView.addArrangedSubview(FeelingButton(image: UIImage(named: "button-mood-notgreat")!, selectedImage: UIImage(named: "button-mood-notgreat-selected")!, title: "Not Great", callback: { [self] in
			statusLabel.text = "Not Great"
			showAnimation(index: 0)
		}))
		greetingStackView.addArrangedSubview(FeelingButton(image: UIImage(named: "button-mood-okay")!, selectedImage: UIImage(named: "button-mood-okay-selected")!, title: "Ok", callback: { [self] in
			statusLabel.text = "Ok"
			showAnimation(index: 1)
		}))
		greetingStackView.addArrangedSubview(FeelingButton(image: UIImage(named: "button-mood-great")!, selectedImage: UIImage(named: "button-mood-great-selected")!, title: "Great!", callback: { [self] in
			statusLabel.text = "Great!"
			showAnimation(index: 2)
		}))

		wholeStackView.addArrangedSubview(statusView)
		statusView.heightAnchor.constraint(equalToConstant: 60).isActive = true
		statusView.widthAnchor.constraint(equalTo: wholeStackView.widthAnchor).isActive = true

		statusView.addSubview(statusLabel)
		statusLabel.leadingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: 32).isActive = true
		statusLabel.bottomAnchor.constraint(equalTo: statusView.bottomAnchor, constant: -16).isActive = true

		wholeStackView.addArrangedSubview(calendarView)
		calendarView.widthAnchor.constraint(equalTo: wholeStackView.widthAnchor).isActive = true
		calendarView.heightAnchor.constraint(equalToConstant: 60).isActive = true
		calendarView.addSubview(todayButton)
		todayButton.centerXAnchor.constraint(equalTo: calendarView.centerXAnchor).isActive = true
		todayButton.centerYAnchor.constraint(equalTo: calendarView.centerYAnchor).isActive = true
		todayButton.addTarget(self, action: #selector(onClickTodayButton), for: .touchUpInside)

		addSubview(wholeStackView)
		wholeStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		wholeStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		wholeStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		wholeStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

		statusView.isHidden = true
		calendarView.isHidden = true
	}

	func showAnimation(index: Int) {
		UIView.animate(withDuration: 0.3) { [self] in
			greetingView.isHidden = true
			self.layoutIfNeeded()
		} completion: { [self] _ in
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				UIView.animate(withDuration: 0.3) {
					statusView.isHidden = false
					self.layoutIfNeeded()
				} completion: { _ in
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						UIView.animate(withDuration: 0.3) { [self] in
							statusView.isHidden = true
							self.layoutIfNeeded()
						} completion: { [self] _ in
							calendarView.isHidden = false
							self.layoutIfNeeded()
							if index == 0 {
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
									self?.delegate?.onClickNotGreat()
								}
							}
						}
					}
				}
			}
		}
	}

	@objc func onClickTodayButton() {
		delegate?.onClickTodayButton()
	}

	func setButtonTitle(title: String) {
		todayButton.setAttributedTitle(title.attributedString(style: .silkabold20, foregroundColor: .black), for: .normal)
	}
}

class FeelingButton: UIControl {
	var image: UIImage!
	var selectedImage: UIImage!
	var title: String!
	var clickCallback: (() -> Void)!
	private var isSelectedControl: Bool = false {
		didSet {
			if isSelectedControl {
				circleView.backgroundColor = .mainBlue
				titleLabel.textColor = .mainBlue
				imageView.tintColor = .white
			} else {
				circleView.backgroundColor = .white
				titleLabel.textColor = .black
				imageView.tintColor = .mainBlue
			}
		}
	}

	private var circleView: UIView = {
		let circleView = UIView()
		circleView.translatesAutoresizingMaskIntoConstraints = false
		circleView.backgroundColor = .white
		circleView.layer.cornerRadius = 28.0
		circleView.setShadow(shadowRadius: 12.0, shadowColor: .mainLightBlue2!, offset: CGSize(width: 0, height: 18), opacity: 0.5)
		return circleView
	}()

	private var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private var titleLabel: UILabel = {
		let titleLabel = UILabel()
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		return titleLabel
	}()

	private lazy var actionButton: UIButton = {
		let actionButton = UIButton()
		actionButton.translatesAutoresizingMaskIntoConstraints = false
		actionButton.addTarget(self, action: #selector(onClickFeelingButton), for: .touchUpInside)
		return actionButton
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	convenience init(image: UIImage, selectedImage: UIImage, title: String, callback: @escaping () -> Void) {
		self.init(frame: .zero)
		self.image = image
		self.selectedImage = selectedImage
		self.title = title
		self.clickCallback = callback
		setupViews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupViews() {
		addSubview(circleView)
		circleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		circleView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		circleView.heightAnchor.constraint(equalToConstant: 56.0).isActive = true
		circleView.widthAnchor.constraint(equalToConstant: 56.0).isActive = true

		circleView.addSubview(imageView)
		imageView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor).isActive = true
		imageView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor).isActive = true
		imageView.heightAnchor.constraint(equalTo: circleView.heightAnchor).isActive = true
		imageView.widthAnchor.constraint(equalTo: circleView.widthAnchor).isActive = true
		imageView.tintColor = .blue
		imageView.image = image

		addSubview(titleLabel)
		titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		titleLabel.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 16.0).isActive = true
		titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		titleLabel.text = title

		addSubview(actionButton)
		actionButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		actionButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		actionButton.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
		actionButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true

		titleLabel.attributedText = title.attributedString(style: .silkabold14, foregroundColor: .black)
	}

	@objc func onClickFeelingButton() {
		isSelectedControl = true
		imageView.image = selectedImage
		clickCallback()
	}
}
