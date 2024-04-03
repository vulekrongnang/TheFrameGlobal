
import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class UserService: NSObject {
    public static let instance = UserService()
    private static let ref: DatabaseReference! = Database.database().reference().child("users")
    
    func getUserByID(userId: String, onSuccess: @escaping ((UserModel) -> Void), onError: @escaping ((String) -> Void), role: Int = 0) {
        UserService.ref.child(userId).observeSingleEvent(of: .value, with: { snapshot in
            // Get user value
            if let value = snapshot.value as? NSDictionary {
                if let userModel = self.parseUserFromDic(data: value) {
                    userModel.role = role
                    onSuccess(userModel)
                } else {
                    onError("Cannot parse User Model")
                }
                
            } else {
                onError("User not found")
            }
          }) { error in
              onError(error.localizedDescription)
          }
    }
    
    func getUserByUID(uid: String, onSuccess: @escaping ((UserModel) -> Void), onError: @escaping ((String) -> Void)) {
        UserService.ref.queryOrdered(byChild: "uid")
            .queryEqual(toValue: uid)
            .queryLimited(toFirst: 1)
            .observeSingleEvent(of: .value, with: { snapshot in
                if let value = snapshot.value as? NSDictionary {
                    if (value.allKeys.isEmpty) {
                        onError("1")
                    } else {
                        value.allKeys.forEach { key in
                            if let keyString = key as? String, let data = value[keyString] as? NSDictionary {
                                if let userModel = self.parseUserFromDic(data: data) {
                                    onSuccess(userModel)
                                } else {
                                    onError("Cannot parse User Model")
                                }
                            }
                        }
                    }
                    
                } else {
                    onError("1")
                }
            }) { error in
                onError(error.localizedDescription)
            }
    }
    
    func createUser(userModel: UserModel, onSuccess: @escaping ((UserModel) -> Void), onError: @escaping ((String) -> Void)) {
        let userDic: NSDictionary =
        ["id": userModel.id ?? "",
         "name": userModel.name ?? "",
         "uid": userModel.uid ?? "",
         "gender": userModel.gender ?? Gender.FeMale.rawValue,
         "birthday": "",
         "phone": userModel.phone ?? ""
        ]
        let userNote = UserService.ref.child(userModel.id ?? "")
        userNote.setValue(userDic) { error, ref in
            if (error == nil) {
                onSuccess(userModel)
            } else {
                onError(error?.localizedDescription ?? "")
            }
        }
    }
    
    func updateUser(userModel: UserModel, onSuccess: @escaping ((UserModel) -> Void), onError: @escaping ((String) -> Void)) {
        var userDic =
        ["id": userModel.id ?? "",
         "avatar": userModel.avatar ?? "",
         "name": userModel.name ?? "",
         "uid": userModel.uid ?? "",
         "gender": userModel.gender ?? Gender.FeMale.rawValue,
         "birthday": userModel.birthday ?? "",
         "phone": userModel.phone ?? ""
        ] as [String : Any]
        if let frames = userModel.frames {
            var framesDic = [String : String]()
            for (index, frameId) in frames.enumerated() {
                framesDic.updateValue(frameId, forKey: "\(index)")
            }
            userDic.updateValue(framesDic, forKey: "frames")
        }
        if let groups = userModel.groups {
            var groupDic = [String: String]()
            for (index, groupId) in groups.enumerated() {
                groupDic.updateValue(groupId, forKey: "\(index)")
            }
            userDic.updateValue(groupDic, forKey: "groups")
        }
        let userNote = UserService.ref.child(userModel.id ?? "")
        userNote.setValue(userDic) { error, ref in
            if (error == nil) {
                onSuccess(userModel)
            } else {
                onError(error?.localizedDescription ?? "")
            }
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
}
