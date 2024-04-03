//
//  GroupDetailViewController.swift
//  The Frame
//
//  Created by Vu Le on 01/04/2024.
//

import Foundation
import UIKit
import RxSwift
import RxGesture
import Kingfisher

class GroupDetailViewController: BaseViewController {
    
    @IBOutlet weak var vBack: UIView!
    @IBOutlet weak var lbGroupName: UILabel!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var ivChangeAvatar: UIImageView!
    @IBOutlet weak var lbUserName: UILabel!
    @IBOutlet weak var ivChangeUserName: UIImageView!
    @IBOutlet weak var lbGroupInfo: UILabel!
    @IBOutlet weak var btnAddPeople: UIImageView!
    @IBOutlet weak var ivAvatar2: UIImageView!
    @IBOutlet weak var lbUserName2: UILabel!
    @IBOutlet weak var tbUser: UITableView!
    
    private var userList = [UserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindEvent()
        updateUserInfo()
        updateGroupInfo()
        initUserTableView()
    }
    
    private func bindEvent() {
        vBack.rx.tapGesture().when(.recognized).subscribe({ [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
    }
    
    private func updateUserInfo() {
        let user = PreferenceUtils.instance.getUser()
        let avatarUrl = URL(string: user.avatar ?? "")
        ivAvatar.kf.setImage(with: avatarUrl, placeholder: UIImage(named: "ic_default_avatar"))
        ivAvatar2.kf.setImage(with: avatarUrl, placeholder: UIImage(named: "ic_default_avatar"))
        lbUserName.text = user.name
        lbUserName2.text = user.name
        
    }
    
    private func updateGroupInfo() {
        let group = PreferenceUtils.instance.getCurrentGroup()
        let user = PreferenceUtils.instance.getUser()
        let memberCount = (group.users?.count ?? 0) - 1
        var string = ""
        string = "Nhóm hiện có \(user.name ?? "") và \(memberCount) thành viên"
        lbGroupName.text = group.name
        lbGroupInfo.text = string
    }
    
    private func initUserTableView() {
        tbUser.register(UserCell.NibObject(), forCellReuseIdentifier: UserCell.identifier)
        tbUser.delegate = self
        tbUser.dataSource = self
        getUserList()
    }
    
    private func getUserList() {
        let group = PreferenceUtils.instance.getCurrentGroup()
        let currentUserId = PreferenceUtils.instance.getUser().id ?? ""

        userList.removeAll()
        
        group.users?.forEach({ user in
            if (user.id != currentUserId) {
                userList.append(user)
            }
        })
        
        tbUser.reloadData()
    }
    
}

extension GroupDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as? UserCell {
            cell.updateView(userModel: self.userList[indexPath.row])
            cell.didSelectDelete = { [weak self] in
                
            }
            return cell
        }
        return UITableViewCell()
    }
}
