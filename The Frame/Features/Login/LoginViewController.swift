//
//  LoginViewController.swift
//  The Frame
//
//  Created by Vu Le on 02/03/2024.
//

import Foundation
import UIKit
import RxSwift
import RxGesture

class LoginViewController: BaseViewController {
    
    @IBOutlet weak var tfPhoneNumber: UITextField!
    @IBOutlet weak var btnLogin: CustomButton!
    
    private let phoneLoginService = PhoneLoginService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneLoginService.delegate = self
        tfPhoneNumber.text = "+84971628167"
        btnLogin.didTap = { [weak self] in
            self?.handleLogin()
        }
    }
    
    private func handleLogin() {
        if validate(value: tfPhoneNumber.text ?? "") {
            self.showLoading()
            self.phoneLoginService.delegate = self
            self.phoneLoginService.requestOTP(phoneNumber: tfPhoneNumber.text ?? "")
        } else {
            showAlertError(message: "Số điện thoại không chính xác. Vui lòng kiểm tra lại")
        }
    }
    
    private func validate(value: String) -> Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: value)
    }
}

extension LoginViewController: PhoneLoginDelegate {
    func requestOTPSuccess(verificationID: String?) {
        hideLoading()
        let verifyVC = VerifyCodeViewController()
        verifyVC.verificationID = verificationID
        verifyVC.phoneNumber = tfPhoneNumber.text
        pushViewController(verifyVC)
    }
    
    func error(message: String) {
        hideLoading()
        showAlertError(message: message)
    }
    
    func verifySuccess(uid: String) {
        
    }
}
