//
//  PhoneLoginService.swift
//  The Frame
//
//  Created by Vu Le on 02/03/2024.
//

import Foundation
import Firebase
import FirebaseAuth

protocol PhoneLoginDelegate: AnyObject {
    func requestOTPSuccess(verificationID: String?)
    func error(message: String)
    func verifySuccess(uid: String)
}

class PhoneLoginService {
    
    var delegate:PhoneLoginDelegate?
    
    func requestOTP(phoneNumber:String){
        
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                if let error = error {
                    var message :String = ""
                    let authError = error as NSError
                    
                    if (authError.code != AuthErrorCode.webContextAlreadyPresented.rawValue) {
                        if authError.code == AuthErrorCode.invalidPhoneNumber.rawValue {
                            message =  "Vui lòng cung cấp số điện thoại hợp lệ"
                        } else {
                            message =  "Có lỗi trong quá trình xử lý, vui lòng thử lại sau"
                        }
                        self.delegate?.error(message: message)
                    }
                    return
                }
                self.delegate?.requestOTPSuccess(verificationID: verificationID)
            }
    }
    
    func authenOTP(code:String, verificationID: String?){
        guard let verificationID =  verificationID  else {return}
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
          verificationCode: code
        )
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                let authError = error as NSError
                        
                if authError.code == AuthErrorCode.invalidVerificationCode.rawValue {
                    self.delegate?.error(message: "OTP không chính xác")
                }else if authError.code == AuthErrorCode.sessionExpired.rawValue {
                    self.delegate?.error(message: "OTP này không còn hợp lệ. Vui lòng yêu cầu lại")
                }else  {
                    self.delegate?.error(message: "OTP không chính xác")
                }
                return
            }
            let uid = authResult?.user.uid ?? ""
            self.delegate?.verifySuccess(uid: uid)
        }
    }
    
    func deleteCurrentUser(onSuccess: @escaping (() -> Void), onError: @escaping ((String) -> Void)) {
        let user = PreferenceUtils.instance.getUser()
        UserService.instance.deleteUser(userId: user.id) {
            PreferenceUtils.instance.deleteUser()
            onSuccess()
        } onError: { String in
            onError("Có lỗi trong quá trình xử lý, vui lòng thử lại sau!")
        }
    }
}
