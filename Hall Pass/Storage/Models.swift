//
//  Models.swift
//  Hall Pass
//
//  Created by Ali Murad on 11/12/2023.
//

import RealmSwift
import Foundation

class Period: Object {
    @Persisted var periodID: String = UUID().uuidString
    @Persisted var periodName: String = ""
    let students = List<Student>()
}

class Student: Object {
    @Persisted var studentID: String = UUID().uuidString
    @Persisted var studentName: String = ""
}
