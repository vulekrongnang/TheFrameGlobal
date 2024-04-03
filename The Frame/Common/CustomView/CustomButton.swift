//
//  CustomButton.swift
//  The Frame
//
//  Created by Vu Le on 03/03/2024.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxGesture

@IBDesignable
open class CustomButton: UIView {
    
    @IBInspectable open var buttonTitle: String = "" {
        didSet {
            setupUI()
        }
    }
 
    var button: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        btn.setTitleColor(UIColor(hexString: "#131523"), for: .normal)
        return btn
    }()
    var backgroundIV: UIImageView = UIImageView()
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    var didTap: (() -> Void)? = nil
    private let disposeBag = DisposeBag()
    private var isHandlingTap = false
    
    fileprivate func setupUI() {
        
        button.setTitle(buttonTitle, for: .normal)
        let background = UIImage(named: "button_background")
        backgroundIV.image = background
        
        
        addSubview(backgroundIV)
        backgroundIV.snp.remakeConstraints { make in
            make.width.height.equalToSuperview()
            make.left.right.bottom.top.equalToSuperview()
        }
        
        backgroundIV.layer.masksToBounds = true
        backgroundIV.cornerRadiusEx = 30
        
        addSubview(button)
        button.snp.remakeConstraints { make in
            make.width.height.equalToSuperview()
            make.left.right.bottom.top.equalToSuperview()
        }
        
        cornerRadiusEx = 30
        
        button.rx.tap.bind { [weak self] in
            if (self?.isHandlingTap == false) {
                self?.preventTap()
                self?.didTap?()
            }
        }.disposed(by: disposeBag)
        
        rx.tapGesture().when(.recognized).subscribe({ [weak self] _ in
            if (self?.isHandlingTap == false) {
                self?.preventTap()
                self?.didTap?()
            }
        }).disposed(by: disposeBag)
        
        backgroundIV.rx.tapGesture().when(.recognized).subscribe({ [weak self] _ in
            if (self?.isHandlingTap == false) {
                self?.preventTap()
                self?.didTap?()
            }
        }).disposed(by: disposeBag)
    }
    
    private func preventTap() {
        isHandlingTap = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
            self?.isHandlingTap = false
        })
    }
}
