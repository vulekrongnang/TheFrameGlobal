import Foundation

class FrameModel: Codable {
    var id: String?
    var name: String?
    var code: String?
    var status: String?
    var group: String?
    var users: [UserModel]?
    var media: [MediaModel]?
    
    init() {}
    
    init(decodeModel: DecodeFrameModel) {
        id = decodeModel.id
        name = decodeModel.name
        code = decodeModel.code
        status = decodeModel.status
        group = decodeModel.group
    }
    
    init(name: String?) {
        self.name = name
    }
}

class DecodeFrameModel: Codable {
    var id: String?
    var name: String?
    var code: String?
    var status: String?
    var group: String?
    
    init(frameModel: FrameModel?) {
        id = frameModel?.id
        name = frameModel?.name
        code = frameModel?.code
        status = frameModel?.status
        group = frameModel?.group
    }
}
