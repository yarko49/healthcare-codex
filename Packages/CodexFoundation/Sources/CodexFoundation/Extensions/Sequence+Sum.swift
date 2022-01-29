import Foundation

public extension Sequence where Element: AdditiveArithmetic {
	func sum() -> Element { reduce(.zero, +) }
}
