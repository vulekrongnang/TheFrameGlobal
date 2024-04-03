import Foundation

class PostModel: Codable {
    var id: String?
    var content: String?
    var mediaUrl: String?
    var mediaType: Int64?
    var userId: String?
    var userName: String?
    var userAvatar: String?
}
