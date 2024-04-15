//
//  PreferenceUtils.swift
//  The Frame
//
//  Created by Vu Le on 30/03/2024.
//

import Foundation

class PreferenceUtils: NSObject {
    
    static let instance = PreferenceUtils()
    
    static let USER_INFO_KEY = "USER_INFO_KEY"
    static let FRAME_INFO_KEY = "FRAME_INFO_KEY"
    static let GROUP_INFO_KEY = "GROUP_INFO_KEY"
    static let POST_INFO_KEY = "POST_INFO_KEY"
    
    func saveUser(user: UserModel) {
        let jsonUserData = try! JSONEncoder().encode(user)
        let jsonUserString = String(data: jsonUserData, encoding: .utf8)!
        UserDefaults.standard.set(jsonUserString,forKey: PreferenceUtils.USER_INFO_KEY)
        UserDefaults.standard.synchronize()
    }
    
    func getUser() -> UserModel {
        let user : UserModel?
        if let jsonUserString =  UserDefaults.standard.string(forKey: PreferenceUtils.USER_INFO_KEY) {
            do {
                user = try! JSONDecoder().decode(UserModel.self, from: (jsonUserString.data(using: .utf8))!)
            }
        } else {
            user = UserModel()
        }
        return user ?? UserModel()
    }
    
    func saveCurrentFrame(frameModel: FrameModel) {
        let jsonFrameData = try! JSONEncoder().encode(frameModel)
        let jsonFrameString = String(data: jsonFrameData, encoding: .utf8)!
        UserDefaults.standard.set(jsonFrameString,forKey: PreferenceUtils.FRAME_INFO_KEY)
        UserDefaults.standard.synchronize()
    }
    
    func getCurrentFrame() -> FrameModel {
        let frame : FrameModel?
        if let jsonFrameString = UserDefaults.standard.string(forKey: PreferenceUtils.FRAME_INFO_KEY) {
            do {
                frame = try! JSONDecoder().decode(FrameModel.self, from: (jsonFrameString.data(using: .utf8))!)
            }
        } else {
            frame = FrameModel()
        }
        return frame ?? FrameModel()
    }
    
    func getRoleString(role: Int) -> String {
        switch role {
        case UserRole.Owner.rawValue:
            return "Sỡ hữu"
        case UserRole.Parent.rawValue:
            return "Cha / Mẹ"
        case UserRole.Brother.rawValue:
            return "Anh / Chị / Em"
        case UserRole.Lover.rawValue:
            return "Người yêu"
        case UserRole.Related.rawValue:
            return "Người thân / họ hàng"
        case UserRole.Friend.rawValue:
            return "Bạn bè"
        default:
            return ""
        }
    }
    
    func getDataUsed() -> String {
        let frame = getCurrentFrame()
        var totalSize: Float = 0
        frame.media?.forEach({ media in
            totalSize += Float((media.size ?? 0))
        })
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        
        let totalSizeInGB = totalSize / 1024 / 1024 / 1024
        if (totalSizeInGB < 0.01) {
            return "0.01"
        } else {
            return formatter.string(from: NSNumber(value: totalSizeInGB)) ?? "0.01"
        }
    }
    
    func saveCurrentGroup(groupModel: GroupModel) {
        let jsonGroupData = try! JSONEncoder().encode(groupModel)
        let jsonGroupString = String(data: jsonGroupData, encoding: .utf8)!
        UserDefaults.standard.set(jsonGroupString, forKey: PreferenceUtils.GROUP_INFO_KEY)
        UserDefaults.standard.synchronize()
    }
    
    func getCurrentGroup() -> GroupModel {
        let group : GroupModel?
        if let jsonGroupString = UserDefaults.standard.string(forKey: PreferenceUtils.GROUP_INFO_KEY) {
            do {
                group = try! JSONDecoder().decode(GroupModel.self, from: (jsonGroupString.data(using: .utf8))!)
            }
        } else {
            group = GroupModel()
        }
        return group ?? GroupModel()
    }
    
    func saveCurrentPost(postModel: PostModel) {
        let jsonPostData = try! JSONEncoder().encode(postModel)
        let jsonPostString = String(data: jsonPostData, encoding: .utf8)!
        UserDefaults.standard.set(jsonPostString, forKey: PreferenceUtils.POST_INFO_KEY)
        UserDefaults.standard.synchronize()
    }
    
    func getCurrentPost() -> PostModel {
        let post : PostModel?
        if let jsonPostString = UserDefaults.standard.string(forKey: PreferenceUtils.POST_INFO_KEY) {
            do {
                post = try! JSONDecoder().decode(PostModel.self, from: (jsonPostString.data(using: .utf8))!)
            }
        } else {
            post = PostModel()
        }
        return post ?? PostModel()
    }
    
    func deleteUser() {
        UserDefaults.standard.removeObject(forKey: PreferenceUtils.USER_INFO_KEY)
        UserDefaults.standard.removeObject(forKey: PreferenceUtils.GROUP_INFO_KEY)
        UserDefaults.standard.removeObject(forKey: PreferenceUtils.POST_INFO_KEY)
        UserDefaults.standard.removeObject(forKey: PreferenceUtils.FRAME_INFO_KEY)
    }
}
