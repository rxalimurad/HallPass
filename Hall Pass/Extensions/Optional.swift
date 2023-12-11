//
//  Optional.swift
//  Break Tracker
//
//  Created by Ali Murad on 11/12/2023.
//

import Foundation
extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}
