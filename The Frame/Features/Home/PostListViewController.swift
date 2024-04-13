//
//  PostListViewController.swift
//  The Frame
//
//  Created by Vu Le on 30/03/2024.
//

import Foundation
import UIKit
import RxSwift
import RxGesture

class PostListViewController: BaseViewController {
    
    @IBOutlet weak var tbPost: UITableView!
    @IBOutlet weak var lbGroupName: UILabel!
    
    private var mCurrentGroup: GroupModel? = nil
    var postList = [PostModel]()
    
    private var mNumberPostLoaded = 0
    private var mNumberPostNeedLoad = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tbPost.delegate = self
        tbPost.dataSource = self
        tbPost.rowHeight = UITableView.automaticDimension
        tbPost.estimatedRowHeight = UITableView.automaticDimension
        tbPost.register(PostCell.NibObject(), forCellReuseIdentifier: PostCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getGroupDetail()
    }
    
    private func getGroupDetail() {
        let currentGroup = PreferenceUtils.instance.getCurrentGroup()
        GroupService.instance.getGroupById(groupId: currentGroup.id ?? "") { [weak self] group in
            self?.updateGroupInfo(group: group)
            self?.handleGetPostList(group: group)
        } onError: { message in
            self.showAlertError(message: message)
        }
    }
    
    private func updateGroupInfo(group: GroupModel) {
        lbGroupName.text = group.name
    }
    
    private func handleGetPostList(group: GroupModel) {
        postList.removeAll()
        tbPost.reloadData()
        
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
            tbPost.reloadData()
        }
    }
}

extension PostListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.identifier, for: indexPath) as? PostCell {
            cell.updateView(post: self.postList[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
}
