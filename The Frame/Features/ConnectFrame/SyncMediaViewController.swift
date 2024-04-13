//
//  SyncMediaViewController.swift
//  The Frame
//
//  Created by Vy Lam on 03/04/2024.
//

import Foundation
import RxSwift
import RxGesture

class SyncMediaViewController: BaseViewController {
    
    
    private var postList = [PostModel]()
    private var mNumberPostLoaded = 0
    private var mNumberPostNeedLoad = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleGetPostList()
    }
    
    private func handleGetPostList() {
        let group = PreferenceUtils.instance.getCurrentGroup()
        mNumberPostLoaded = 0
        mNumberPostNeedLoad = group.posts?.count ?? 0
        group.posts?.forEach({ postId in
            PostService.instance.getPostById(postId: postId) { [weak self] postModel in
                self?.postList.append(postModel)
                self?.checkGetPostListDone()
            } onError: { [weak self] message in
                self?.checkGetPostListDone()
            }
        })
    }
    
    private func checkGetPostListDone() {
        mNumberPostLoaded += 1
        if (mNumberPostLoaded == mNumberPostNeedLoad) {
            handleUpdateFrame()
        }
    }
    
    private func handleUpdateFrame() {
        var mediaList = [MediaModel]()
        var add = 1
        self.postList.forEach({ post in
            let media = MediaModel()
            media.id = Date().currentTimeMillis() + Int64(add)
            media.type = post.mediaType
            media.url = post.mediaUrl
            mediaList.append(media)
            add += 1
        })
        
        let frame = PreferenceUtils.instance.getCurrentFrame()
        frame.media = mediaList
        FrameService.instance.updateFrame(frame: frame) { [weak self] updatedFrame in
            PreferenceUtils.instance.saveCurrentFrame(frameModel: updatedFrame)
            self?.appDelegate.showHomeView()
        } onError: { [weak self] message in
            self?.showAlert(message: message, onClickOK: { [weak self] in
                self?.appDelegate.showHomeView()
            })
        }
    }
}
