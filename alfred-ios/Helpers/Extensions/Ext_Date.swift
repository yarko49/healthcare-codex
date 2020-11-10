import Foundation

extension Date {
    var relationalString: String {
        if Calendar.current.isDateInToday(self) {
            let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: self, to: Date())
            let hours = diffComponents.hour
            return hours == 0 ? Str.now : DateFormatter.hmma.string(from: self)
        } else if Calendar.current.isDateInYesterday(self) {
            return Str.yesterday
        } else {
            return DateFormatter.MMMdd.string(from: self)
        }
    }
}
