import Foundation

extension Collection where Element: BinaryInteger {
	func average() -> Element { isEmpty ? .zero : sum() / Element(count) }
	func average<T: FloatingPoint>() -> T { isEmpty ? .zero : T(sum()) / T(count) }
}
