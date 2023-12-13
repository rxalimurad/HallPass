//
//  DBManager.swift
//  Hall Pass
//
//  Created by Ali Murad on 11/12/2023.
//

import RealmSwift
import Foundation

class RealmManager {
    init() {
        
        

    }
    
    static let shared = RealmManager()
    private let realm = try! Realm()
    private var notificationTokens: [NotificationToken] = []
    
    func observeRealmChanges<T: Object>(_ objectType: T.Type, completion: @escaping ([T]) -> Void) {
        let realm = try! Realm()
        let results = realm.objects(objectType)
        
        let token = results.observe { changes in
            switch changes {
            case .initial(let initialResults):
                completion(Array(initialResults))
            case .update(let updatedResults, _, _, _):
                completion(Array(updatedResults))
            case .error(let error):
                print("Error observing changes: \(error)")
            }
        }
        notificationTokens.append(token)
    }
    
    func stopObserving() {
        notificationTokens.forEach { $0.invalidate() }
        notificationTokens.removeAll()
    }
    
    // Function to add a new period
    func addPeriod(periodName: String) {
        try! realm.write {
            let newPeriod = Period()
            newPeriod.periodName = periodName
            realm.add(newPeriod)
        }
    }
    func deletePeriod(periodID: String) {
        if let period = realm.object(ofType: Period.self, forPrimaryKey: periodID) {
            do {
                try realm.write {
                    realm.delete(period.students) // Delete students associated with the period
                    realm.delete(period) // Delete the period itself
                }
            } catch {
                print("Error deleting period: \(error)")
            }
        } else {
            print("Period not found")
            // Handle case when the specified period is not found
        }
    }
    func deleteStudent(student: Student) {
        do {
            try realm.write {
                realm.delete(student)
            }
        } catch {
            print("Error deleting student: \(error)")
        }
    }
    
    // Function to add a student to a specific period
    func addStudentToPeriod(periodID: String, studentName: String) {
        if let period = realm.object(ofType: Period.self, forPrimaryKey: periodID) {
            try! realm.write {
                let newStudent = Student()
                newStudent.studentName = studentName
                period.students.append(newStudent)
            }
        } else {
            print("Period not found")
            // Handle case when the specified period is not found
        }
    }
    func getPeriods() -> Results<Period>? {
        let realm = try! Realm()
        return realm.objects(Period.self)
    }
    
    func getStudents(for periodID: String) -> List<Student>? {
        let realm = try! Realm()
        if let period = realm.object(ofType: Period.self, forPrimaryKey: periodID) {
            let sortedStudents = period.students
            let sortedArray = Array(sortedStudents) // Convert to Array
            
            let sortedList = List<Student>() // Create an empty List of Student objects

            for student in sortedArray {
                sortedList.append(student) // Add each student from the array to the List
            }
            
            return sortedList
        }
        return nil
    }


    
    
    func startSession(student: Student, signOut: Date, period: Period) -> Session{
        try! realm.write {
            let session = Session()
            session.signOut = signOut
            session.student = student
            session.period = period
            realm.add(session)
            UserDefaults.standard.sessionID = session.sessionID
            return session
        }
    }
    
    func endSession(sessionID: String, signin: Date) {
        let sessionToUpdate = realm.object(ofType: Session.self, forPrimaryKey: sessionID)
        
        if let session = sessionToUpdate {
            do {
                try realm.write {
                    session.signin = signin
                    realm.add(session, update: .modified)
                    UserDefaults.standard.sessionID = nil
                }
                print("Session signOut updated successfully")
            } catch {
                print("Error updating session signOut: \(error)")
            }
        } else {
            print("Session not found")
        }
    }
    
    func getSession(with sessionID: String) -> Session? {
        let realm = try! Realm()
        return realm.object(ofType: Session.self, forPrimaryKey: sessionID)
    }
    
    func getSessions() -> Results<Session>? {
        let realm = try! Realm()
        return realm.objects(Session.self)
        
    }
    
    
    func deleteAllPeriods() {
        
    }
    func updatePeriodsOrder(from: Int, to: Int) {
        let realm = try! Realm()
        let existingPeriods = realm.objects(Period.self)
        let periodsList = List<Period>()
        periodsList.append(objectsIn: existingPeriods)
        
        periodsList.move(from: from, to: to)
    }
    func updateStudentOrder(period: String?, from: Int, to: Int) {
        guard let period else { return }
        let realm = try! Realm()
        let studentList = getStudents(for: period)
        studentList?.move(from: from, to: to)
    }


}

