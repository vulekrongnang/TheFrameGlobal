//
//  CreateGroupViewController.swift
//  The Frame
//
//  Created by Vu Le on 03/03/2024.
//

import Foundation
import RxSwift
import RxGesture

class CreateGroupViewController: BaseViewController {
    
    @IBOutlet weak var tfGroupName: UITextField!
    @IBOutlet weak var btnStart: CustomButton!
    @IBOutlet weak var vBack: UIView!
    @IBOutlet weak var ivBack: UIImageView!
    
    var isShowBack = false
    var didCreatedGroup: (() -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnStart.didTap = { [weak self] in
            self?.handleCreateGroup()
        }
        
        ivBack.image = ivBack.image?.withRenderingMode(.alwaysTemplate)
        ivBack.tintColor = .white
        
        vBack.isHidden = !isShowBack
        vBack.rx.tapGesture().when(.recognized).subscribe({[weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
        
        if isShowBack {
            btnStart.button.setTitle("TẠO NHÓM", for: .normal)
        }
    }
    
    private func handleCreateGroup() {
        if (self.tfGroupName.text?.isEmpty == true) {
            self.showAlert(message: "Vui lòng nhập tên nhóm để tiếp tục!")
        } else {
            self.showLoading()
            self.createGroup()
        }
    }
    
    private func createGroup() {
        let currentUser = PreferenceUtils.instance.getUser()
        let groupModel = GroupModel()
        groupModel.id = "\(Date().currentTimeMillis())"
        groupModel.name = self.tfGroupName.text ?? ""
        groupModel.users = [UserModel]()
        groupModel.users?.append(currentUser)
        GroupService.instance.createGroup(group: groupModel) { [weak self] group in
            if self?.isShowBack == false {
                PreferenceUtils.instance.saveCurrentGroup(groupModel: group)
            }
            self?.updateUser(group: group)
        } onError: { [weak self] message in
            self?.hideLoading()
            self?.showAlertError(message: message)
        }
    }
    
    private func updateUser(group: GroupModel) {
        let currentUser = PreferenceUtils.instance.getUser()
        if (currentUser.groups == nil) {
            currentUser.groups = [String]()
        }
        currentUser.groups?.append(group.id ?? "")
        UserService.instance.updateUser(userModel: currentUser) { [weak self] user in
            guard let self = self else {return}
            self.hideLoading()
            PreferenceUtils.instance.saveUser(user: user)
            if (self.isShowBack) {
                self.didCreatedGroup?()
                self.navigationController?.popViewController(animated: true)
            } else {
                self.appDelegate.showHomeView()
            }
        } onError: { [weak self] message in
            self?.hideLoading()
            self?.showAlertError(message: message)
        }
    }
}
