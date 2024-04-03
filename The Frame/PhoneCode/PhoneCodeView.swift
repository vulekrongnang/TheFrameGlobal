//
//  PhoneCodeView.swift
//  The Frame
//
//  Created by Vu Le on 03/03/2024.
//

import Foundation
import UIKit

@objc
public protocol PhoneCodeViewDelegate: AnyObject {
    func codeView(sender: PhoneCodeView, didFinishInput code: String) -> Bool
}

@IBDesignable
open class PhoneCodeView: UIControl {
    @IBInspectable open var length: Int = 6 {
        didSet {
            setupUI()
        }
    }

    @IBOutlet open weak var delegate: PhoneCodeViewDelegate?

    var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 8
        return stackView
    }()

    fileprivate var items: [PhoneCodeItemView] = []
    open var code: String {
        get {
            let items = stackView.arrangedSubviews.map({$0 as! PhoneCodeItemView})
            let values = items.map({$0.textField.text ?? ""})
            return values.joined()
        }
        set {
            let array = newValue.map(String.init)
            for i in 0..<length {
                let item = stackView.arrangedSubviews[i] as! PhoneCodeItemView
                item.textField.text = i < array.count ? array[i] : ""
            }
            if !stackView.arrangedSubviews.compactMap({$0 as? UITextField}).filter({$0.isFirstResponder}).isEmpty {
                self.becomeFirstResponder()
            }
        }
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        setupUI()

        let tap = UITapGestureRecognizer(target: self, action: #selector(becomeFirstResponder))
        addGestureRecognizer(tap)
    }

    fileprivate func setupUI() {
        if stackView.superview == nil {
            addSubview(stackView)
            stackView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.height.equalTo(68)
            }
        }
        stackView.arrangedSubviews.forEach{($0.removeFromSuperview())}

        for i in 0..<length {
            let itemView = generateItem()
            itemView.textField.deleteDelegate = self
            itemView.textField.delegate = self
            itemView.tag = i
            itemView.textField.tag = i
            stackView.addArrangedSubview(itemView)
        }
    }

    open func generateItem() -> PhoneCodeItemView {
        let type = PhoneCodeItemView.self
        let typeStr = type.description().components(separatedBy: ".").last ?? ""
        let bundle = Bundle(for: type)
        return bundle
            .loadNibNamed(typeStr,
                          owner: nil,
                          options: nil)?
            .last as! PhoneCodeItemView
    }

    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        let items = stackView.arrangedSubviews
            .map({$0 as! PhoneCodeItemView})
        return (items.filter({($0.textField.text ?? "").isEmpty}).first ?? items.last)!.becomeFirstResponder()
    }

    @discardableResult
    override open func resignFirstResponder() -> Bool {
        stackView.arrangedSubviews.forEach({$0.resignFirstResponder()})
        return true
    }

    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupUI()
    }
}

extension PhoneCodeView: UITextFieldDelegate, PhoneCodeTextFieldDelegate {

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if string == "" { //is backspace
            return true
        }

        if !textField.hasText {
            let index = textField.tag
            let item = stackView.arrangedSubviews[index] as! PhoneCodeItemView
            item.textField.text = string
            sendActions(for: .valueChanged)
            if index == length - 1 { //is last textfield
                if (delegate?.codeView(sender: self, didFinishInput: self.code) ?? false) {
                    textField.resignFirstResponder()
                }
                return false
            }

            _ = stackView.arrangedSubviews[index + 1].becomeFirstResponder()
        }

        return false
    }

    public func deleteBackward(sender: PhoneCodeTextField, prevValue: String?) {
        for i in 1..<length {
            let itemView = stackView.arrangedSubviews[i] as! PhoneCodeItemView

            guard itemView.textField.isFirstResponder, (prevValue?.isEmpty ?? true) else {
                continue
            }

            let prevItem = stackView.arrangedSubviews[i-1] as! PhoneCodeItemView
            if itemView.textField.text?.isEmpty ?? true {
                prevItem.textField.text = ""
                _ = prevItem.becomeFirstResponder()
            }
        }
        sendActions(for: .valueChanged)
    }
}
