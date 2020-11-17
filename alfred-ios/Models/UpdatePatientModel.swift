import Foundation

struct UpdatePatientModel: Codable {
	let op, path: String?
	let value: String?
}

typealias Edit = [UpdatePatientModel]
