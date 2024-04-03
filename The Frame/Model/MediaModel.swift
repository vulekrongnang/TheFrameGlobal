import Foundation

class MediaModel:  Codable {
    var id: Int64?
    var url: String?
    var type: Int64?
    var size: Int64?
    var selected: Bool? = false
}
