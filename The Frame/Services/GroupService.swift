import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase


class GroupService: NSObject {
    
    public static let instance = GroupService()
    private static let ref: DatabaseReference! = Database.database().reference().child("groups")
    
    func getGroupById(groupId: String, onSuccess: @escaping ((GroupModel) -> Void), onError: @escaping ((String) -> Void)) {
        GroupService.ref.child(groupId).observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? NSDictionary {
                if let groupModel = self.parseGroupFromDic(data: value) {
                    onSuccess(groupModel)
                } else {
                    onError("Cannot parse Group Model")
                }
                
            } else {
                onError("Group not found")
            }
          }) { error in
            onError(error.localizedDescription)
          }
    }
    
    func createGroup(group: GroupModel, onSuccess: @escaping ((GroupModel) -> Void), onError: @escaping ((String) -> Void)) {
        let groupDic: NSDictionary =
        ["id": group.id ?? "",
         "name": group.name ?? "",
         "avatar": group.avatar ?? ""
        ]
        let groupNote = GroupService.ref.child(group.id ?? "")
        groupNote.setValue(groupDic) { error, ref in
            group.users?.forEach({ user in
                let groupUserDic: NSDictionary =
                ["id": user.id ?? "",
                 "role": 0
                ]
                groupNote.child("users").child(user.id ?? "").setValue(groupUserDic)
            })
            onSuccess(group)
        }
    }
    
    func updateGroup(group: GroupModel, onSuccess: @escaping ((GroupModel) -> Void), onError: @escaping ((String) -> Void)) {
        var groupDic =
        ["id": group.id ?? "",
         "name": group.name ?? "",
         "avatar": group.avatar ?? "",
         "frame": group.frame ?? ""
        ] as [String: Any]
        
        if let posts = group.posts {
            var postsDic = [String: String]()
            for (index, postId) in posts.enumerated() {
                postsDic.updateValue(postId, forKey: "\(index)")
            }
            groupDic.updateValue(postsDic, forKey: "posts")
        }
        
        let groupNote = GroupService.ref.child(group.id ?? "")
        groupNote.setValue(groupDic) { error, ref in
            group.users?.forEach({ user in
                let groupUserDic: NSDictionary =
                ["id": user.id ?? "",
                 "role": 0
                ]
                groupNote.child("users").child(user.id ?? "").setValue(groupUserDic)
            })
            onSuccess(group)
        }
    }
    
    private func parseGroupFromDic(data: NSDictionary) -> GroupModel? {
        do {
            let json = try JSONSerialization.data(withJSONObject: data)
            let decodeGroup: DecodeGroupModel = try JSONDecoder().decode(DecodeGroupModel.self, from: json)
            let groupModel = GroupModel(decodeModel: decodeGroup)
            var users = [UserModel]()
            var medias = [MediaModel]()
            if let allKeys = data["users"] as? NSDictionary {
                allKeys.forEach { (key: Any, value: Any) in
                    if let userDic = value as? NSDictionary {
                        if let userModel = self.parseUserFromDic(data: userDic) {
                            users.append(userModel)
                        }
                    }
                }
            }
            if let allMediaKeys = data["medias"] as? NSDictionary {
                allMediaKeys.forEach { (key: Any, value: Any) in
                    if let mediaDic = value as? NSDictionary {
                        if let mediaModel = self.parseMediaFromDic(data: mediaDic) {
                            medias.append(mediaModel)
                        }
                    }
                }
            }
            groupModel.users = users
            groupModel.medias = medias
            return groupModel
        } catch {
            print("Parse Group error")
            return nil
        }
    }
    
    private func parseUserFromDic(data: NSDictionary) -> UserModel? {
        do {
            let json = try JSONSerialization.data(withJSONObject: data)
            let userModel: UserModel = try JSONDecoder().decode(UserModel.self, from: json)
            return userModel
        } catch {
            print("Parse User error")
            return nil
        }
    }
    
    private func parseMediaFromDic(data: NSDictionary) -> MediaModel? {
        do {
            let json = try JSONSerialization.data(withJSONObject: data)
            let mediaModel: MediaModel = try JSONDecoder().decode(MediaModel.self, from: json)
            return mediaModel
        } catch {
            print("Parse Media error")
            return nil
        }
    }
}
