//
//  Models.swift
//  Hall Pass
//
//  Created by Ali Murad on 11/12/2023.
//

import RealmSwift
import Foundation

class Period: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString // Primary key
    @Persisted var periodName: String = ""
    @Persisted var students = List<Student>()
    
}

class Student: Object {
    @Persisted var studentID: String = UUID().uuidString
    @Persisted var studentName: String = ""
}


class Session: Object {
    @Persisted(primaryKey: true) var sessionID: String = UUID().uuidString
    @Persisted var signOut = Date()
    @Persisted var signin = Date()
    @Persisted var student: Student?
    @Persisted var period: Period?
   
}
