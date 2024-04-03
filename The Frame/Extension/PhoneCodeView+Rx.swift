//
//  PhoneCodeView+Rx.swift
//  The Frame
//
//  Created by Vu Le on 03/03/2024.
//

import Foundation
import RxSwift
import RxCocoa

public extension Reactive where Base: PhoneCodeView {
    var code: ControlProperty<String> {
        return controlProperty(editingEvents: [.allEditingEvents, .valueChanged],
                               getter: { codeView in
            codeView.code
        }, setter: { codeView, value in
            codeView.code = value
        })
    }
}
