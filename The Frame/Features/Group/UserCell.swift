//
//  UserCell.swift
//  The Frame
//
//  Created by Vu Le on 03/04/2024.
//

import UIKit
import RxSwift
import RxGesture

class UserCell: UITableViewCell {

    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lbUserName: UILabel!
    @IBOutlet weak var btnDeleteUser: UIImageView!
    
    private var disposeBag = DisposeBag()
    private var isHandlingClick = false
    
    var didSelectDelete: (() -> Void)? = nil
    
    func updateView(userModel: UserModel) {
        
        let avatarUrl = URL(string: userModel.avatar ?? "")
        ivAvatar.kf.setImage(with: avatarUrl, placeholder: UIImage(named: "ic_default_avatar"))
        lbUserName.text = userModel.name
        
        btnDeleteUser.rx.tapGesture().when(.recognized).subscribe({[weak self] _ in
            if (self?.isHandlingClick == false) {
                self?.preventClick()
                self?.didSelectDelete?()
            }
        }).disposed(by: disposeBag)
    }
    
    private func preventClick() {
        isHandlingClick = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {[weak self] in
            self?.isHandlingClick = false
        })
    }
}
