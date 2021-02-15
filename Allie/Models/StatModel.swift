import Foundation
import HealthKit

struct StatModel {
	let type: HealthKitQuantityType
	let dataPoints: [StatsDataPoint]
}

struct StatsDataPoint {
	let date: Date
	let value: HKQuantity?
}
