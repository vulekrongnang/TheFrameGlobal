//
//  VerifyCodeViewController.swift
//  The Frame
//
//  Created by Vu Le on 03/03/2024.
//

import Foundation
import UIKit
import RxSwift
import RxGesture

class VerifyCodeViewController: BaseViewController {
    
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var lbResend: UILabel!
    @IBOutlet weak var vPhoneCode: PhoneCodeView!
    @IBOutlet weak var btnVerify: CustomButton!
    
    var phoneNumber: String?
    var verificationID: String?
    private let phoneLoginService = PhoneLoginService()
    private var isPhoneCodeLengthValid = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneLoginService.delegate = self
        
        lbMessage.text = "Mã OTP được gửi tới số điện thoại\n\(phoneNumber ?? "")"
        let codeLength = vPhoneCode.length
        vPhoneCode.rx.code.map({$0.count == codeLength})
            .bind(onNext: { [weak self] isValid in
                self?.isPhoneCodeLengthValid = isValid
            })
            .disposed(by: disposeBag)
        btnVerify.didTap = { [weak self] in
            guard let self = self else {return}
            if (self.isPhoneCodeLengthValid == true) {
                self.showLoading()
                self.phoneLoginService.authenOTP(code: self.vPhoneCode.code, verificationID: self.verificationID)
            }
        }
        lbResend.rx.tapGesture().when(.recognized).subscribe({ [weak self] _ in
            self?.showLoading()
            self?.phoneLoginService.requestOTP(phoneNumber: self?.phoneNumber ?? "")
        }).disposed(by: disposeBag)
    }
    
    private func getUserByUID(uid: String) {
        UserService.instance.getUserByUID(uid: uid, onSuccess: { [weak self] user in
            PreferenceUtils.instance.saveUser(user: user)
            self?.getListGroup(user: user)
        }, onError: { [weak self] message in
            if (message == "1") {
                self?.createUserByID(uid: uid)
            } else {
                self?.hideLoading()
                self?.showAlertError(message: message)
            }
        })
    }
    
    private func createUserByID(uid: String) {
        let userModel = UserModel()
        userModel.id = "\(Date().currentTimeMillis())"
        userModel.name = "User \(userModel.id ?? "")"
        userModel.uid = uid
        userModel.phone = phoneNumber
        userModel.gender = Gender.FeMale.rawValue
        userModel.birthday = ""
        UserService.instance.createUser(userModel: userModel, onSuccess: { [weak self] user in
            PreferenceUtils.instance.saveUser(user: user)
            self?.hideLoading()
            self?.appDelegate.showCreateGroupView()
        }, onError: { [weak self] message in
            self?.hideLoading()
            self?.showAlertError(message: message)
        })
    }
    
    private func getListGroup(user: UserModel) {
        if let userId = user.id {
            UserService.instance.getUserByID(userId: userId, onSuccess: { [weak self] user in
                PreferenceUtils.instance.saveUser(user: user)
                if let groups = user.groups {
                    if groups.isEmpty {
                        self?.appDelegate.showCreateGroupView()
                    } else {
                        self?.getGroupDetail(groupId: groups.first ?? "")
                    }
                } else {
                    self?.appDelegate.showCreateGroupView()
                }
            }) { [weak self] message in
                self?.hideLoading()
                self?.showAlertError(message: message)
            }
        }
    }
    
    private func getGroupDetail(groupId: String) {
        GroupService.instance.getGroupById(groupId: groupId, onSuccess: { [weak self] group in
            PreferenceUtils.instance.saveCurrentGroup(groupModel: group)
            self?.appDelegate.showHomeView()
        }) { [weak self] message in
            self?.hideLoading()
            self?.showAlertError(message: message)
        }
    }
}

extension VerifyCodeViewController: PhoneLoginDelegate {
    func requestOTPSuccess(verificationID: String?) {
        hideLoading()
        self.verificationID = verificationID
    }
    
    func error(message: String) {
        hideLoading()
        showAlertError(message: message)
    }
    
    func verifySuccess(uid: String) {
        getUserByUID(uid: uid)
    }
}
