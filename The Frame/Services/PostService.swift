//
//  PostService.swift
//  The Frame
//
//  Created by Vu Le on 30/03/2024.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class PostService: NSObject {
    public static let instance = PostService()
    private static let ref: DatabaseReference! = Database.database().reference().child("posts")
    
    func getPostById(postId: String, onSuccess: @escaping ((PostModel) -> Void), onError: @escaping ((String) -> Void)) {
        PostService.ref.child(postId).observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? NSDictionary {
                if let postModel = self.parsePostFromDic(data: value) {
                    onSuccess(postModel)
                } else {
                    onError("Cannot parse Post Model")
                }
                
            } else {
                onError("Post not found")
            }
          }) { error in
            onError(error.localizedDescription)
          }
    }
    
    func createPost(postModel: PostModel, onSuccess: @escaping ((PostModel) -> Void), onError: @escaping ((String) -> Void)) {
        let postDic: NSDictionary =
        [ "id": postModel.id ?? "",
          "content": postModel.content ?? "",
          "mediaUrl": postModel.mediaUrl ?? "",
          "mediaType": postModel.mediaType ?? "",
          "userId": postModel.userId ?? "",
          "userName": postModel.userName ?? "",
          "userAvatar": postModel.userAvatar ?? "",
        ]
        let postNote = PostService.ref.child(postModel.id ?? "")
        postNote.setValue(postDic) { error, ref in
            if (error != nil) {
                onError(error?.localizedDescription ?? "")
            } else {
                onSuccess(postModel)
            }
        }
    }
    
    private func parsePostFromDic(data: NSDictionary) -> PostModel? {
        do {
            let json = try JSONSerialization.data(withJSONObject: data)
            let postModel: PostModel = try JSONDecoder().decode(PostModel.self, from: json)
            return postModel
        } catch {
            print("Parse Post error")
            return nil
        }
    }
}
