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

	class var allieLightGray: UIColor {
		UIColor(named: "AllieLightGray")!
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

	class var allieRed: UIColor {
		UIColor(named: "AllieRed")!
	}

	class var medications: UIColor {
		UIColor(named: "Medications")!
	}

	class var weight: UIColor {
		UIColor(named: "Weight")!
	}

	class var activity: UIColor {
		UIColor(named: "Activity")!
	}

	class var bloodPressure: UIColor {
		UIColor(named: "BloodPressure")!
	}

	class var heartRate: UIColor {
		UIColor(named: "HeartRate")!
	}

	class var restingHeartRate: UIColor {
		UIColor(named: "HeartRate")!
	}

	class var insulin: UIColor {
		UIColor(named: "Insulin")!
	}

	class var bloodGlucose: UIColor {
		UIColor(named: "BloodGlucose")!
	}

	class var allieGreen: UIColor {
		UIColor(named: "AllieGreen")!
	}
}

extension UIColor {
	static let grey = UIColor(named: "Grey")!
	static let veryLightGrey = UIColor(named: "VeryLightGrey")
	static let lightBackground = UIColor(named: "LightBackground")
	static let lightGrey = UIColor(named: "LightGrey")!
	static let blue = UIColor(named: "Blue")
	static let chart = UIColor(named: "Chart")
	static let profile = UIColor(named: "Profile")
	static let swipe = UIColor(named: "Swipe")
	static let google = UIColor(named: "Google")
	static let next = UIColor(named: "Next")
	static let pcp = UIColor(named: "PCP")!
	static let cursorOrange = UIColor(named: "CursorOrange")!
	static let weightLabel = UIColor(named: "WeightLabel")
	static let enterGrey = UIColor(named: "EnterGrey")!
	static let tableViewSeparator = UIColor(named: "TableViewSeparator")
	// Coach Cards
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

extension UIColor {
	static let mainBlue = UIColor(hex: "#546DF1")
	static let mainLightBlue = UIColor(hex: "#72BDF3")
	static let mainLightBlue2 = UIColor(hex: "#B4BCE5")
	static let mainDarkBlue = UIColor(hex: "#2B387A")
	static let mainRed = UIColor(hex: "#FF6B6B")
	static let mainLightRed = UIColor(hex: "#F4C3B9")
	static let mainGreen = UIColor(hex: "#A2D4C0")
	static let mainLightGreen = UIColor(hex: "#CFFFEB")
	static let mainDarkGreen = UIColor(hex: "#2B5B48")
	static let mainGray = UIColor(hex: "#323232")
	static let mainLightGray = UIColor(hex: "#CDCDCD")
	static let mainBackground = UIColor(hex: "#F7FBFF")
	static let mainWhite = UIColor(hex: "#F6F6F8")
	static let mainShadow = UIColor(hex: "#C8DDEF")!
}
