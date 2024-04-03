import Foundation

class GroupModel: Codable {
    var id: String?
    var name: String?
    var avatar: String?
    var frame: String?
    var posts: [String]?
    var users: [UserModel]?
    var medias: [MediaModel]?
    
    init() {}
    
    init(decodeModel: DecodeGroupModel) {
        id = decodeModel.id
        name = decodeModel.name
        avatar = decodeModel.avatar
        frame = decodeModel.frame
        posts = decodeModel.posts
    }
    
    init(name: String?) {
        self.name = name
    }
}

class DecodeGroupModel: Codable {
    var id: String?
    var name: String?
    var avatar: String?
    var frame: String?
    var posts: [String]?
    
    init(groupModel: GroupModel?) {
        id = groupModel?.id
        name = groupModel?.name
        avatar = groupModel?.avatar
        frame = groupModel?.frame
        posts = groupModel?.posts
    }
}
