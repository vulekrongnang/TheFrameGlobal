//
//  MediaService.swift
//  The Frame
//
//  Created by Vu Le on 30/03/2024.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import YPImagePicker


class MediaService: NSObject {
    public static let instance = MediaService()
    private static let ref = Storage.storage().reference()
    
    func uploadMedia(url: URL?, data: Data?, type: MediaType,
                     onSuccess: @escaping ((UploadedMediaModel) -> Void),
                     onError: @escaping ((String) -> Void)) {
        if let url = url {
            let metadata = StorageMetadata()
            metadata.contentType = "video/mp4"
            let storageRef = MediaService.ref.child("media/\(Date().currentTimeMillis())")
            _ = storageRef.putFile(from: url, metadata: metadata) { metadata, error in
                guard let metadata = metadata else {
                    onError("Media bị lỗi")
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                let size = metadata.size
                // You can also access to download URL after upload.
                storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        onError("Media bị lỗi")
                        return
                    }
                    let uploadedMedia = UploadedMediaModel()
                    uploadedMedia.url = downloadURL.absoluteString
                    uploadedMedia.size = size
                    uploadedMedia.type = Int64(type.rawValue)
                    onSuccess(uploadedMedia)
              }
            }
        } else if let data = data {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let storageRef = MediaService.ref.child("media/\(Date().currentTimeMillis())")
            let uploadTask = storageRef.putData(data, metadata: metadata) { metadata, error in
                guard let metadata = metadata else {
                    onError("Media bị lỗi")
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                let size = metadata.size
                // You can also access to download URL after upload.
                storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        onError("Media bị lỗi")
                        return
                    }
                    let uploadedMedia = UploadedMediaModel()
                    uploadedMedia.url = downloadURL.absoluteString
                    uploadedMedia.size = size
                    uploadedMedia.type = Int64(type.rawValue)
                    onSuccess(uploadedMedia)
              }
            }
        } else {
            onError("Media bị lỗi")
        }
    }
}
