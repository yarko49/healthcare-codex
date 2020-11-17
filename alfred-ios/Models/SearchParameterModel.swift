import Foundation

struct SearchParameter: Codable {
	var sort: String?
	var count: Int?
	var code: String?

	enum CodingKeys: String, CodingKey {
		case sort
		case count
		case code
	}
}
