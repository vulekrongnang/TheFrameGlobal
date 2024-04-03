//
//  BaseViewController.swift
//  The Frame
//
//  Created by Vu Le on 02/03/2024.
//

import Foundation
import UIKit
import RxSwift
import RxRelay
import SPPermissions

class BaseViewController: UIViewController, SPPermissionsDelegate {
    
    var disposeBag : DisposeBag = DisposeBag()
    var onPermissionAllowed : (()->Void)?
    
    private var loadingView : UIView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func showAlertError(message: String){
        if !UIApplication.topVC()!.isKind(of: UIAlertController.self)  {
            showAlert(title: "", message: message)
        }
    }
    
    func showAlert(title: String? = "", message: String?, onClickOK: (() -> Void)? = nil) {
        let alertCtr = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Đóng", style: .cancel) { (action) in
            onClickOK?()
        }
        alertCtr.addAction(action)
        if !UIApplication.topVC()!.isKind(of: UIAlertController.self){
            UIApplication.topVC()?.present(alertCtr, animated: true,completion: {
                
            })
        }
    }
    
    func showAlertConfirm(title: String? = "", message: String?, onConfirmed: @escaping (() -> Void )) {
        let alertCtr = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Hủy", style: .cancel) { (action) in
            
        }
        let confirmAction = UIAlertAction(title: "Đồng ý", style: .default) { (action) in
            alertCtr.dismiss(animated: true) {
                onConfirmed()
            }
        }
        alertCtr.addAction(confirmAction)
        alertCtr.addAction(cancelAction)
        if !UIApplication.topVC()!.isKind(of: UIAlertController.self){
            UIApplication.topVC()?.present(alertCtr, animated: true,completion: {
                
            })
        }
    }
    
    func getStatusBarHeight() -> CGFloat? {
        let window = UIApplication.shared.windows.first
        let topPadding = window?.safeAreaInsets.top
        return topPadding
    }
    
    func checkPermissionPhoto() ->Bool{
       let authorized = SPPermissions.Permission.photoLibrary.authorized
       if !authorized {
           let controller = SPPermissions.native([.photoLibrary])

           controller.delegate = self

           controller.present(on: self)
       }
       
       return authorized
   }
    
    func didAllowPermission(_ permission: SPPermissions.Permission) {
        onPermissionAllowed?()
    }
    
    func didDeniedPermission(_ permission: SPPermissions.Permission) {
        
    }
    
    func didHidePermissions(_ permissions: [SPPermissions.Permission]) {
        
    }
    
    func pushViewController(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showLoading() {
        var isShowing = false
        self.view.subviews.forEach { view in
            if view.tag == 10 {
                isShowing = true
            }
        }
        if !isShowing {
            loadingView = UIView ()
            loadingView?.frame = UIScreen.main.bounds
            loadingView?.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
            loadingView?.tag = 10
            let ai = UIActivityIndicatorView()
            ai.hidesWhenStopped = true
            ai.style  = .large
            ai.center = loadingView!.center
            ai.color = .white
            ai.startAnimating()
            loadingView?.addSubview(ai)
            self.view.addSubview(loadingView!)
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view.subviews.forEach { view in
                if view.tag == 10 {
                    view.removeFromSuperview()
                }
            }
            self.loadingView?.removeFromSuperview()
            self.loadingView =  nil
        }
    }
}
