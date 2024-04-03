//
//  PhoneCodeItemView.swift
//  The Frame
//
//  Created by Vu Le on 03/03/2024.
//

import Foundation
import UIKit

open class PhoneCodeItemView: UIView {
    
    @IBOutlet weak var textField: PhoneCodeTextField!
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        textField.text = ""
        isUserInteractionEnabled = false
    }
    
    override open func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    override open func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
}
