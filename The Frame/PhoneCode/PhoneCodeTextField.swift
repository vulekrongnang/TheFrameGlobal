//
//  PhoneCode.swift
//  The Frame
//
//  Created by Vu Le on 03/03/2024.
//

import Foundation
import UIKit

public protocol PhoneCodeTextFieldDelegate: AnyObject {
    func deleteBackward(sender: PhoneCodeTextField, prevValue: String?)
}

open class PhoneCodeTextField: UITextField {
    
    weak open var deleteDelegate: PhoneCodeTextFieldDelegate?

    override open func deleteBackward() {
        let prevValue = text
        super.deleteBackward()
        deleteDelegate?.deleteBackward(sender: self, prevValue: prevValue)
    }
}
