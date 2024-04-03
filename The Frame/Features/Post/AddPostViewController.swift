//
//  AddPostViewController.swift
//  The Frame
//
//  Created by Vu Le on 30/03/2024.
//

import Foundation
import UIKit
import RxSwift
import RxGesture
import YPImagePicker
import AVKit

class AddPostViewController: BaseViewController {
    
    @IBOutlet weak var vBack: UIView!
    @IBOutlet weak var ivContent: UIImageView!
    @IBOutlet weak var tvCaption: UITextView!
    @IBOutlet weak var btnAddPost: CustomButton!
    
    var selectedMedias = [YPMediaItem]()
    private var selectedMediaType = MediaType.Image
    private var selectedMediaUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindEvent()
        showSelectedMedia()
        tvCaption.delegate = self
    }
    
    private func bindEvent() {
        vBack.rx.tapGesture().when(.recognized).subscribe({ [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
        
        btnAddPost.didTap = { [weak self] in
            self?.handleUploadMedia()
        }
    }
    
    private func showSelectedMedia() {
        self.selectedMedias.forEach { mediaItem in
            switch mediaItem {
            case .photo(let photo):
                self.selectedMediaType = .Image
                self.ivContent.image = photo.image
            case .video(let video):
                self.selectedMediaType = .Video
                self.ivContent.image = video.thumbnail
            }
        }
    }
    
    private func handleUploadMedia() {
        showLoading()
        self.selectedMedias.forEach { mediaItem in
            switch mediaItem {
            case .photo(let photo):
                let imageData = photo.image.jpegData(compressionQuality: 1.0)
                MediaService.instance.uploadMedia(url: nil, data: imageData, type: .Image, onSuccess: { [weak self] uploadedMedia in
                    self?.selectedMediaUrl = uploadedMedia.url ?? ""
                    self?.addPost()
                }, onError: { [weak self] message in
                    self?.hideLoading()
                    self?.showAlertError(message: message)
                })
            case .video(let video):
                MediaService.instance.uploadMedia(url: video.url, data: nil, type: .Video, onSuccess: { [weak self] uploadedMedia in
                    self?.selectedMediaUrl = uploadedMedia.url ?? ""
                    self?.addPost()
                }, onError: { [weak self] message in
                    self?.hideLoading()
                    self?.showAlertError(message: message)
                })
            }
        }
    }
    
    private func addPost() {
        let currentUser = PreferenceUtils.instance.getUser()
        let postModel = PostModel()
        postModel.id = "\(Date().currentTimeMillis())"
        postModel.content = tvCaption.text == "Thêm mô tả" ? "" : tvCaption.text
        postModel.mediaType = Int64(selectedMediaType.rawValue)
        postModel.mediaUrl = selectedMediaUrl
        postModel.userId = currentUser.id ?? ""
        postModel.userName = currentUser.name ?? ""
        postModel.userAvatar = currentUser.avatar ?? ""
        
        PostService.instance.createPost(postModel: postModel) { [weak self] post in
            PreferenceUtils.instance.saveCurrentPost(postModel: post)
            self?.updateGroup(post: post)
        } onError: { [weak self] message in
            self?.hideLoading()
            self?.showAlertError(message: message)
        }
    }
    
    private func updateGroup(post: PostModel) {
        let currentGroup = PreferenceUtils.instance.getCurrentGroup()
        if (currentGroup.posts == nil) {
            currentGroup.posts = [String]()
        }
        currentGroup.posts?.append(post.id ?? "")
        
        GroupService.instance.updateGroup(group: currentGroup) { [weak self] group in
            PreferenceUtils.instance.saveCurrentGroup(groupModel: group)
            self?.hideLoading()
            self?.showAlert(message: "Thêm bài đăng thành công") { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        } onError: { [weak self] message in
            self?.hideLoading()
            self?.showAlertError(message: message)
        }
    }
}

extension AddPostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Thêm mô tả" {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Thêm mô tả"
        }
    }
}
