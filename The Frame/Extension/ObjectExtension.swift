//
//  ObjectExtension.swift
//  The Frame
//
//  Created by Vu Le on 03/03/2024.
//

import Foundation

extension NSObject {
    
    class var nameOfClass: String {
        return NSStringFromClass(self).components(separatedBy: ".").last! as String
    }
    
    // reuseidentifier for obtaining the cell
    class var identifier: String {
        return String(format: "%@_identifier", self.nameOfClass)
    }
}
