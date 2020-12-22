//
//  QuestionnaireNC.swift
//  alfred-ios
//

import Foundation
import UIKit

class QuestionnaireNavigationController: UINavigationController {
	override func viewDidLoad() {
		super.viewDidLoad()

		let navBar = navigationBar
		navBar.isTranslucent = false
		navBar.barTintColor = UIColor.lightBackground
		navBar.setBackgroundImage(UIImage(), for: .default)
		navBar.shadowImage = UIImage()
		navBar.layoutIfNeeded()

		navBar.titleTextAttributes = [NSAttributedString.Key.font: Font.sfProBold.of(size: 24), NSAttributedString.Key.foregroundColor: UIColor.black]
	}
}
