import Foundation

public extension Date {
	var relationalString: String {
		if Calendar.current.isDateInToday(self) {
			let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: self, to: Date())
			let hours = diffComponents.hour
			return hours == 0 ? NSLocalizedString("NOW", comment: "Now") : DateFormatter.hmma.string(from: self)
		} else if Calendar.current.isDateInYesterday(self) {
			return NSLocalizedString("YESTERDAY", comment: "Yesterday")
		} else {
			return DateFormatter.MMMdd.string(from: self)
		}
	}

	var startOfWeek: Date? {
		Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
	}

	var endOfWeek: Date? {
		guard let startOfWeek = startOfWeek else { return nil }
		var components = DateComponents()
		components.day = 6
		components.hour = 23
		components.minute = 59
		components.second = 59
		return Calendar.current.date(byAdding: components, to: startOfWeek)
	}

	var nextWeek: Date? {
		Calendar.current.date(byAdding: .day, value: 7, to: self)
	}

	var previousWeek: Date? {
		Calendar.current.date(byAdding: .day, value: -7, to: self)
	}

	var startOfMonth: Date? {
		let components = Calendar.current.dateComponents([.year, .month], from: self)
		return Calendar.current.date(from: components)
	}

	var startOfNextMonth: Date? {
		guard
			let startOfMonth = startOfMonth else { return nil }
		return Calendar.current.date(byAdding: .month, value: 1, to: startOfMonth)
	}

	var endOfMonth: Date? {
		guard let startOfNextMonth = startOfNextMonth else { return nil }
		return Calendar.current.date(byAdding: .second, value: -1, to: startOfNextMonth)
	}

	var previousMonth: Date? {
		guard let startOfMonth = startOfMonth else { return nil }
		return Calendar.current.date(byAdding: .month, value: -1, to: startOfMonth)
	}

	var startOfYear: Date? {
		var components = Calendar.current.dateComponents([.year], from: self)
		components.month = 1
		components.day = 1
		return Calendar.current.date(from: components)
	}

	var startOfNextYear: Date? {
		guard let startOfYear = startOfYear else { return nil }
		var components = Calendar.current.dateComponents([.year], from: startOfYear)
		if let year = components.year {
			components.year = year + 1
		}
		return Calendar.current.date(from: components)
	}

	var endOfYear: Date? {
		guard let startOfNextYear = startOfNextYear else { return nil }
		return Calendar.current.date(byAdding: .second, value: -1, to: startOfNextYear)
	}

	var previousYear: Date? {
		guard let startOfYear = startOfYear else { return nil }
		var components = Calendar.current.dateComponents([.year], from: startOfYear)
		if let year = components.year {
			components.year = year - 1
		}
		return Calendar.current.date(from: components)
	}

	var numberOfDaysInMonth: Int {
		guard let range = Calendar.current.range(of: .day, in: .month, for: self) else { return 30 }
		return range.count
	}

	var byRemovingFractionalSeconds: Date? {
		let calendar = Calendar.current
		var newComponents = DateComponents()
		newComponents.timeZone = .current
		newComponents.second = calendar.component(.second, from: self)
		newComponents.hour = calendar.component(.hour, from: self)
		newComponents.day = calendar.component(.day, from: self)
		newComponents.month = calendar.component(.month, from: self)
		newComponents.year = calendar.component(.year, from: self)
		return calendar.date(from: newComponents)
	}
}
