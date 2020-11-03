
import Foundation


class ProfileHelper {
    
    static func computeHeight(value: Int) -> (Int, Int) {
        let feet =  (value) / 100 != 0 ? (value ) / 100 : (value) / 10
        let inches = (value) / 100 != 0 ? (value) % 100 : (value) % 10
        return (feet, inches)
    }
    
    static func getFirstName() -> String {
        return DataContext.shared.getDisplayFirstName()
    }
   
    static func getBirthdate() -> Int {
        return DataContext.shared.getBirthday()
    }
    
    static func getGender() -> Gender {
        var gender: Gender?
        if DataContext.shared.userModel?.gender == .male {
            gender = .male
        } else if DataContext.shared.userModel?.gender == .female {
            gender = .female
        }
        return gender ?? Gender.female
    }
}
