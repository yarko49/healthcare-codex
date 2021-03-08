import Foundation

struct UpdatePatientModel: Codable {
	let op: String?
	let path: String?
	let value: String?
}

typealias UpdatePatientModels = [UpdatePatientModel]
