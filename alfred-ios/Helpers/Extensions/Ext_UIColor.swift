import UIKit
import UIColor_Hex_Swift

extension UIColor {
    static let white = UIColor.white
    static let black = UIColor.black
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
    static let googleColor = UIColor(named : "GoogleColor")
    static let next = UIColor(named: "Next")
    static let pcpColor = UIColor(named: "PCPColor")!
    static let darkText = UIColor(named: "DarkText")
    static let onboardingBackground = UIColor(named: "OnboardingBackground")!
    static let cursorOrange = UIColor(named: "CursorOrange")!
    static let restingHR = UIColor(named: "RestingHRColor2")
    static let weightLblColor = UIColor(named: "WeightLblColor")
    //Coach Cards
    static let weightBG = UIColor(named: "WeightBG")!
    static let activityBG = UIColor(named: "ActivityBG")!
    static let bloodPressureBG = UIColor(named: "BloodPressureBG")!
    static let surveyBG = UIColor(named: "SurveyBG")!
    static let medicationBG = UIColor(named: "MedicationBG")!
    
    //Measurement Cards
    static let weightDataBG = UIColor(named: "WeightDataBG")!
    static let activityDataBG = UIColor(named: "ActivityDataBG")!
    static let bloodPressureDataBG = UIColor(named: "BloodPressureDataBG")!
    static let surveyDataBG = UIColor(named: "SurveyDataBG")!
    static let medicationDataBG = UIColor(named: "MedicationDataBG")!
    
    // Status
    static let statusLow = UIColor(named: "StatusLow")!
    static let statusGreen = UIColor(named: "StatusGreen")!
    static let statusYellow = UIColor(named: "StatusYellow")!
    static let statusRed = UIColor(named: "StatusRed")!
    
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        let updatedHex = hex.count < 9 ? hex + "ff" : hex
        
        if updatedHex.hasPrefix("#") {
            let start = updatedHex.index(updatedHex.startIndex, offsetBy: 1)
            let hexColor = String(updatedHex[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}
