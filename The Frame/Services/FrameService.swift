//
//  FrameService.swift
//  The Frame
//
//  Created by Vu Le on 30/03/2024.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class FrameService: NSObject {
    public static let instance = FrameService()
    private static let ref: DatabaseReference! = Database.database().reference().child("frames")
    
    func getFrameById(frameId: String, onSuccess: @escaping ((FrameModel) -> Void), onError: @escaping ((String) -> Void)) {
        FrameService.ref.child(frameId).observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? NSDictionary {
                if let frameModel = self.parseFrameFromDic(data: value) {
                    onSuccess(frameModel)
                } else {
                    onError("Cannot parse Frame Model")
                }
                
            } else {
                onError("Frame not found")
            }
          }) { error in
            onError(error.localizedDescription)
          }
    }
    
    func createFrame(frame: FrameModel, onSuccess: @escaping ((FrameModel) -> Void), onError: @escaping ((String) -> Void)) {
        let frameDic: NSDictionary =
        ["id": frame.id ?? "",
         "code": frame.code ?? "",
         "name": frame.name ?? "",
         "group": frame.group ?? ""
        ]
        let frameNote = FrameService.ref.child(frame.id ?? "")
        frameNote.setValue(frameDic) { error, ref in
            frame.users?.forEach({ user in
                let frameUserDic: NSDictionary =
                ["id": user.id ?? "",
                 "role": 0
                ]
                frameNote.child("users").child(user.id ?? "").setValue(frameUserDic)
            })
            self.updateFrameMedia(frame: frame, onSuccess: onSuccess, onError: onError)
        }
    }
    
    func updateFrame(frame: FrameModel, onSuccess: @escaping ((FrameModel) -> Void), onError: @escaping ((String) -> Void)) {
        let frameDic: NSDictionary =
        ["id": frame.id ?? "",
         "code": frame.code ?? "",
         "name": frame.name ?? "",
         "group": frame.group ?? "",
        ]
        let frameNote = FrameService.ref.child(frame.id ?? "")
        frameNote.setValue(frameDic) { error, ref in
            if (error != nil) {
                onError(error?.localizedDescription ?? "")
            } else {
                frame.users?.forEach({ user in
                    let frameUserDic: NSDictionary =
                    ["id": user.id ?? "",
                     "role": user.role ?? UserRole.Owner.rawValue
                    ]
                    frameNote.child("users").child(user.id ?? "").setValue(frameUserDic)
                })
                self.updateFrameMedia(frame: frame, onSuccess: onSuccess, onError: onError)
            }
            
        }
    }
    
    func updateFrameMedia(frame: FrameModel, onSuccess: @escaping ((FrameModel) -> Void), onError: @escaping ((String) -> Void)) {
        var frameMediaDic = [String : NSDictionary]()
        frame.media?.forEach({ mediaModel in
            frameMediaDic.updateValue(
                [
                    "id": mediaModel.id ?? 0,
                    "url": mediaModel.url ?? "",
                    "size": mediaModel.size ?? 0,
                    "type": mediaModel.type ?? 0
                ]
                , forKey: "\(mediaModel.id ?? 0)")
        })
        let frameMediaNote = FrameService.ref.child(frame.id ?? "").child("media")
        frameMediaNote.setValue(frameMediaDic) { error, ref in
            if (error != nil) {
                onError(error?.localizedDescription ?? "")
            } else {
                onSuccess(frame)
            }
        }
    }
    
    func checkFrameStatus(frame: FrameModel, onSuccess: @escaping ((String?) -> Void), onError: @escaping ((String?) -> Void)) {
        FrameService.ref.child(frame.id ?? "").child("status").setValue("ping \(Date().currentTimeMillis())")
        FrameService.ref.child(frame.id ?? "").child("status").observe(.value, with: { dataSnapshot in
            if let data = dataSnapshot.value as? String {
                if data.contains("pong") {
                    let timeStamp = data.split(separator: " ")[1].lowercased()
                    let time = Date().currentTimeMillis() - (Int64(timeStamp) ?? 0)
                    if time < 5000 {
                        onSuccess(frame.id)
                    } else {
                        onError(frame.id)
                    }
                }
            } else {
                onError(frame.id)
            }
        }) { error in
            onError(frame.id)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            onError(frame.id)
        })
    }
    
    func checkFrameConnectStatus(frame: FrameModel, onSuccess: @escaping ((String?) -> Void), onError: @escaping ((String?) -> Void)) {
        FrameService.ref.child(frame.id ?? "").child("status").observe(.value, with: { dataSnapshot in
            if let data = dataSnapshot.value as? String {
                if data.contains("pong") {
                    onSuccess(frame.id)
                }
            }
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 15, execute: {
            FrameService.ref.child(frame.id ?? "").child("status").setValue("ping \(Date().currentTimeMillis())")
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 45, execute: {
            FrameService.ref.child(frame.id ?? "").child("status").setValue("ping \(Date().currentTimeMillis())")
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 75, execute: {
            FrameService.ref.child(frame.id ?? "").child("status").setValue("ping \(Date().currentTimeMillis())")
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 120, execute: {
            onError(frame.id)
        })
    }
    
    private func parseFrameFromDic(data: NSDictionary) -> FrameModel? {
        do {
            let json = try JSONSerialization.data(withJSONObject: data)
            let decodeFrame: DecodeFrameModel = try JSONDecoder().decode(DecodeFrameModel.self, from: json)
            let frameModel = FrameModel(decodeModel: decodeFrame)
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
            if let allMediaKeys = data["media"] as? NSDictionary {
                allMediaKeys.forEach { (key: Any, value: Any) in
                    if let mediaDic = value as? NSDictionary {
                        if let mediaModel = self.parseMediaFromDic(data: mediaDic) {
                            medias.append(mediaModel)
                        }
                    }
                }
            }
            frameModel.users = users
            frameModel.media = medias
            return frameModel
        } catch {
            print("Parse Frame error")
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
            print("Parse User error")
            return nil
        }
    }
}
