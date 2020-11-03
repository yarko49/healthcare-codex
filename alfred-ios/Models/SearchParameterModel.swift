import Foundation

struct SearchParameter : Codable {
    var sort : String?
    var count: Int?
    
    enum CodingKeys: String, CodingKey {
        case sort = "_sort"
        case count = "_count"
    }
}

