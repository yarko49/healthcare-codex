import UIKit

extension UIColor {
	class var allieBlack: UIColor {
		UIColor(named: "AllieBlack")!
	}

	class var allieGray: UIColor {
		UIColor(named: "AllieGray")!
	}

	class var allieChatDark: UIColor {
		UIColor(named: "AllieChatDark")!
	}

	class var allieChatLight: UIColor {
		UIColor(named: "AllieChatLight")!
	}

	class var allieLighterGray: UIColor {
		UIColor(named: "AllieLighterGray")!
	}

	class var allieOrange: UIColor {
		UIColor(named: "AllieOrange")!
	}

	class var allieWhite: UIColor {
		UIColor(named: "AllieWhite")!
	}

	class var allieSeparator: UIColor {
		UIColor(named: "AllieSeparator")!
	}

	class var allieLightText: UIColor {
		UIColor(named: "AllieLightText")!
	}
}

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
	static let chart = UIColor(named: "Chart")
	static let profile = UIColor(named: "Profile")
	static let weight = UIColor(named: "Weight")
	static let activity = UIColor(named: "Activity")
	static let bloodPressure = UIColor(named: "BloodPressure")
	static let heartRate = UIColor(named: "HeartRate")
	static let swipe = UIColor(named: "Swipe")
	static let google = UIColor(named: "Google")
	static let next = UIColor(named: "Next")
	static let pcp = UIColor(named: "PCP")!
	static let onboardingBackground = UIColor(named: "OnboardingBackground")!
	static let cursorOrange = UIColor(named: "CursorOrange")!
	static let restingHeartRate = UIColor(named: "RestingHeartRate")
	static let weightLabel = UIColor(named: "WeightLabel")
	static let enterGrey = UIColor(named: "EnterGrey")!
	static let tableViewSeparator = UIColor(named: "TableViewSeparator")
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

	public convenience init(rgbHex hex: UInt) {
		let alpha = hex & 0xFF
		let blue = (hex >> 8) & 0xFF
		let green = (hex >> 16) & 0xFF
		let red = (hex >> 24) & 0xFF

		self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha) / 255.0)
	}
}
