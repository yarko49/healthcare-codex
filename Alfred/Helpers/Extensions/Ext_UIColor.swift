import UIKit

extension UIColor {
	static let grey = UIColor(named: "Grey")!
	static let veryLightGrey = UIColor(named: "VeryLightGrey")
	static let lightBackground = UIColor(named: "LightBackground")
	static let lightGrey = UIColor(named: "LightGrey")!
	static let blue = UIColor(named: "Blue")
	static let purple400 = UIColor(named: "Purple400")
	static let red400 = UIColor(named: "Red400")
	static let orange600 = UIColor(named: "Orange600")
	static let yellow300 = UIColor(named: "Yellow300")
	static let green300 = UIColor(named: "Green300")
	static let chartColor = UIColor(named: "ChartColor")
	static let profile = UIColor(named: "Profile")
	static let weightColor = UIColor(named: "WeightColor")
	static let activityColor = UIColor(named: "ActivityColor")
	static let bloodPressureColor = UIColor(named: "BloodPressureColor")
	static let heartRateColor = UIColor(named: "HeartRateColor")
	static let swipeColor = UIColor(named: "SwipeColor")
	static let googleColor = UIColor(named: "GoogleColor")
	static let next = UIColor(named: "Next")
	static let pcpColor = UIColor(named: "PCPColor")!
	static let darkText = UIColor(named: "DarkText")
	static let onboardingBackground = UIColor(named: "OnboardingBackground")!
	static let cursorOrange = UIColor(named: "CursorOrange")!
	static let restingHR = UIColor(named: "RestingHRColor2")
	static let weightLblColor = UIColor(named: "WeightLblColor")
	static let enterGrey = UIColor(named: "EnterGrey")!
	static let tableViewSeparatorColor = UIColor(named: "TableViewSeparatorColor")
	// Coach Cards
	static let weightBackground = UIColor(named: "WeightBackground")!
	static let activityBackground = UIColor(named: "ActivityBackground")!
	static let bloodPressureBackground = UIColor(named: "BloodPressureBackground")!
	static let surveyBackground = UIColor(named: "SurveyBackground")!
	static let medicationBackground = UIColor(named: "MedicationBackground")!

	// Measurement Cards
	static let weightDataBackground = UIColor(named: "WeightDataBackground")!
	static let activityDataBackground = UIColor(named: "ActivityDataBackground")!
	static let bloodPressureDataBackground = UIColor(named: "BloodPressureDataBackground")!
	static let surveyDataBackground = UIColor(named: "SurveyDataBackground")!
	static let medicationDataBackground = UIColor(named: "MedicationDataBackground")!
	static let defaultDataBackground = UIColor(named: "DefaultDataBackground")!

	// Status
	static let statusLow = UIColor(named: "StatusLow")!
	static let statusGreen = UIColor(named: "StatusGreen")!
	static let statusYellow = UIColor(named: "StatusYellow")!
	static let statusOrange = UIColor(named: "StatusOrange")!
	static let statusRed = UIColor(named: "StatusRed")!
	static let statusDeepRed = UIColor(named: "StatusDeepRed")!

	static let dark60 = UIColor(named: "Dark60")!

	public convenience init?(hex: String) {
		let red, green, blue, alpha: CGFloat

		let updatedHex = hex.count < 9 ? hex + "ff" : hex

		if updatedHex.hasPrefix("#") {
			let start = updatedHex.index(updatedHex.startIndex, offsetBy: 1)
			let hexColor = String(updatedHex[start...])

			if hexColor.count == 8 {
				let scanner = Scanner(string: hexColor)
				var hexNumber: UInt64 = 0

				if scanner.scanHexInt64(&hexNumber) {
					red = CGFloat((hexNumber & 0xFF000000) >> 24) / 255
					green = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255
					blue = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255
					alpha = CGFloat(hexNumber & 0x000000FF) / 255

					self.init(red: red, green: green, blue: blue, alpha: alpha)
					return
				}
			}
		}

		return nil
	}
}
