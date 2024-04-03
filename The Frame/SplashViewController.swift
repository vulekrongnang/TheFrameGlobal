//
//  SplashViewController.swift
//  The Frame
//
//  Created by Vu Le on 02/03/2024.
//

import Foundation
import UIKit
import SnapKit

class SplashViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let background = UIImage(named: "app_background")
        let backgroundIV = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        backgroundIV.image = background
        
        view.addSubview(backgroundIV)
        
        let logo = UIImage(named: "app_logo")
        let logoIV = UIImageView(frame: CGRect(x: 0, y: 0, width: 180, height: 87))
        logoIV.image = logo
        
        view.addSubview(logoIV)
        
        logoIV.snp.makeConstraints { make in
            make.width.equalTo(180)
            make.height.equalTo(87)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.8)
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
            self?.handleNextScreen()
        })
    }
    
    private func handleNextScreen() {
        let user = PreferenceUtils.instance.getUser()
        let group = PreferenceUtils.instance.getCurrentGroup()
        if !(user.id ?? "").isEmpty {
            if !(group.id ?? "").isEmpty {
                self.appDelegate.showHomeView()
            } else {
                self.getListGroup()
            }
        } else {
            self.showLoginView()
        }
    }
    
    private func getListGroup() {
        let currentUser = PreferenceUtils.instance.getUser()
        if let userId = currentUser.id {
            UserService.instance.getUserByID(userId: userId, onSuccess: { [weak self] user in
                guard let self = self else {return}
                PreferenceUtils.instance.saveUser(user: user)
                if let groups = user.groups {
                    if groups.isEmpty {
                        self.appDelegate.showCreateGroupView()
                    } else {
                        self.getGroupDetail(groupId: groups.first ?? "")
                    }
                } else {
                    self.appDelegate.showCreateGroupView()
                }
            }) { [weak self] message in
                self?.showAlertError(message: message)
            }
        }
    }
    
    private func getGroupDetail(groupId: String) {
        GroupService.instance.getGroupById(groupId: groupId, onSuccess: { [weak self] group in
            PreferenceUtils.instance.saveCurrentGroup(groupModel: group)
            self?.appDelegate.showHomeView()
        }) { [weak self] message in
            self?.showAlertError(message: message)
        }
    }
    
    private func showLoginView() {
        let loginVC = LoginViewController()
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
}
