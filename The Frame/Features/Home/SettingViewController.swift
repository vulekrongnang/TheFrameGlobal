//
//  SettingViewController.swift
//  The Frame
//
//  Created by Vu Le on 31/03/2024.
//

import Foundation
import UIKit
import RxSwift
import RxGesture
import Kingfisher
import YPImagePicker

class SettingViewController: BaseViewController {
    
    @IBOutlet weak var btnAddGroup: UIImageView!
    @IBOutlet weak var btnSetting: UIImageView!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var btnChangeAvatar: UIImageView!
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var lbGroupCount: UILabel!
    @IBOutlet weak var tfSearchGroup: UITextField!
    @IBOutlet weak var tbGroup: UITableView!
    @IBOutlet weak var btnDeleteAccount: UIButton!
    
    weak var parrentVC: HomeViewController? = nil
    var didSelectCreateGroup: (() -> Void)? = nil
    
    private var groupList = [GroupModel]()
    private var filterGroup = [GroupModel]()
    private var numberGroupNeedLoad = 0
    private var numberGroupLoaded = 0
    
    private var isInEditMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindEvent()
        updateUserInfo()
        initGroupTableView()
    }
    
    private func bindEvent() {
        btnAddGroup.rx.tapGesture().when(.recognized).subscribe({[weak self] _ in
            self?.didSelectCreateGroup?()
        }).disposed(by: disposeBag)
        btnSetting.rx.tapGesture().when(.recognized).subscribe({[weak self] _ in
            self?.handleEditMode()
        }).disposed(by: disposeBag)
        btnChangeAvatar.rx.tapGesture().when(.recognized).subscribe({[weak self] _ in
            self?.selectNewAvatar()
        }).disposed(by: disposeBag)
        tfSearchGroup.rx.text.changed.bind { [weak self] _ in
            self?.searchGroup()
        }.disposed(by: disposeBag)
        btnDeleteAccount.rx.tap.bind { [weak self] _ in
            self?.handleDeleteAccount()
        }.disposed(by: disposeBag)
    }
    
    private func updateUserInfo() {
        let user = PreferenceUtils.instance.getUser()
        let avatarUrl = URL(string: user.avatar ?? "")
        ivAvatar.kf.setImage(with: avatarUrl, placeholder: UIImage(named: "ic_default_avatar"))
        tfUserName.text = user.name
        lbGroupCount.text = "\(user.groups?.count ?? 0)"
    }
    
    private func initGroupTableView() {
        tbGroup.register(GroupCell.NibObject(), forCellReuseIdentifier: GroupCell.identifier)
        tbGroup.delegate = self
        tbGroup.dataSource = self
        getGroupList()
    }
    
    private func getGroupList() {
        let user = PreferenceUtils.instance.getUser()
        numberGroupNeedLoad = user.groups?.count ?? 1
        numberGroupLoaded = 0
        groupList.removeAll()
        
        user.groups?.forEach({ groupId in
            GroupService.instance.getGroupById(groupId: groupId) { [weak self] groupModel in
                self?.groupList.append(groupModel)
                self?.numberGroupLoaded += 1
                self?.checkLoadGroupListDone()
            } onError: { [weak self] message in
                self?.numberGroupLoaded += 1
                self?.checkLoadGroupListDone()
            }
        })
    }
    
    private func checkLoadGroupListDone() {
        if (numberGroupLoaded == numberGroupNeedLoad) {
            searchGroup()
        }
    }
    
    private func searchGroup() {
        let text = (tfSearchGroup.text ?? "").lowercased()
        filterGroup.removeAll()
        if text.isEmpty {
            filterGroup = groupList
        } else {
            groupList.forEach { group in
                let groupName = (group.name ?? "").lowercased()
                if groupName.contains(text) {
                    filterGroup.append(group)
                }
            }
        }
        tbGroup.reloadData()
    }
    
    func didCreatedGroup() {
        updateUserInfo()
        initGroupTableView()
    }
    
    func handleEditMode() {
        isInEditMode = !isInEditMode
        btnSetting.image = isInEditMode ? UIImage(named: "ic_setting_active") : UIImage(named: "ic_setting_normal")
        tbGroup.reloadData()
    }
    
    func handleDeleteAccount() {
        showAlertConfirm(message: "Bạn có chắc muốn xóa tài khoản của mình không?") {
            PhoneLoginService().deleteCurrentUser { [weak self] in
                self?.showAlert(message: "Xóa user thành công!") { [weak self] in
                    self?.appDelegate.showLoginView()
                }
            } onError: { [weak self] message in
                self?.showAlertError(message: message)
            }

        }
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterGroup.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: GroupCell.identifier, for: indexPath) as? GroupCell {
            cell.updateView(group: self.filterGroup[indexPath.row], isEditing: isInEditMode)
            cell.didSelectEdit = { [weak self] in
                let vc = GroupDetailViewController()
                self?.parrentVC?.navigationController?.pushViewController(vc, animated: true)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = filterGroup[indexPath.row]
        PreferenceUtils.instance.saveCurrentGroup(groupModel: group)
        if let parrent = parrentVC {
            parrent.selectedTab = 0
            parrent.switchTab()
            parrent.pagerVC.setViewControllers([parrent.listVC[0]], direction: .reverse, animated: false)
        }
    }
}

// MARK: - Change Avatar
extension SettingViewController {
    func selectNewAvatar() {
        var config = YPImagePickerConfiguration()
        config.isScrollToChangeModesEnabled = true
        config.onlySquareImagesFromCamera = true
        config.usesFrontCamera = true
        config.showsPhotoFilters = false
        config.shouldSaveNewPicturesToAlbum = true
        config.albumName = "The Frame Global"
        config.startOnScreen = YPPickerScreen.library
        config.screens = [.library, .photo]
        config.showsCrop = .none
        config.targetImageSize = YPImageSize.original
        config.overlayView = UIView()
        config.hidesStatusBar = true
        config.hidesBottomBar = false
        config.hidesCancelButton = false
        config.preferredStatusBarStyle = UIStatusBarStyle.default
        config.bottomMenuItemSelectedTextColour = UIColor.red
        config.bottomMenuItemUnSelectedTextColour = UIColor.blue
        config.library.maxNumberOfItems = 1
        config.library.mediaType = .photo
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [weak self] items, cancelled in
            if !cancelled {
                self?.updateNewAvatar(items: items)
            }
            picker.dismiss(animated: true, completion: nil)
        }
        parrentVC?.present(picker, animated: true)
    }
    
    func updateNewAvatar(items: [YPMediaItem]) {
        self.parrentVC?.showLoading()
        if let photo = items.singlePhoto {
            let imageData = photo.image.jpegData(compressionQuality: 1.0)
            MediaService.instance.uploadMedia(url: nil, data: imageData, type: .Image, onSuccess: { [weak self] uploadedMedia in
                self?.handleSaveUserAfterUpdateAvatar(avatarURL: uploadedMedia.url ?? "")
            }, onError: { [weak self] message in
                self?.parrentVC?.hideLoading()
                self?.showAlertError(message: message)
            })
        } else {
            self.parrentVC?.hideLoading()
        }
    }
    
    func handleSaveUserAfterUpdateAvatar(avatarURL: String) {
        let user = PreferenceUtils.instance.getUser()
        user.avatar = avatarURL
        UserService.instance.updateUser(userModel: user) { [weak self] userModel in
            PreferenceUtils.instance.saveUser(user: userModel)
            self?.parrentVC?.hideLoading()
            self?.updateUserInfo()
        } onError: { [weak self] message in
            self?.parrentVC?.hideLoading()
            self?.showAlertError(message: message)
        }
    }
}
