//
//  GroupCell.swift
//  The Frame
//
//  Created by Vu Le on 31/03/2024.
//

import UIKit
import RxSwift
import RxGesture

class GroupCell: UITableViewCell {

    @IBOutlet weak var lbGroupName: UILabel!
    @IBOutlet weak var lbInfo: UILabel!
    @IBOutlet weak var btnEdit: UIImageView!
    @IBOutlet weak var btnDelete: UIImageView!
    
    private var disposeBag = DisposeBag()
    private var isHandlingClick = false
    var didSelectDelete: (() -> Void)? = nil
    var didSelectEdit: (() -> Void)? = nil
    
    func updateView(group: GroupModel, isEditing: Bool) {
        lbGroupName.text = group.name
        lbInfo.text = "\(group.users?.count ?? 0) thành viên"
        
        btnEdit.isHidden = !isEditing
        btnDelete.isHidden = true//!isEditing
        
        btnDelete.rx.tapGesture().when(.recognized).subscribe({[weak self] _ in
            self?.didSelectDelete?()
        }).disposed(by: disposeBag)
        
        btnEdit.rx.tapGesture().when(.recognized).subscribe({[weak self] _ in
            if (self?.isHandlingClick == false) {
                self?.preventClick()
                self?.didSelectEdit?()
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
