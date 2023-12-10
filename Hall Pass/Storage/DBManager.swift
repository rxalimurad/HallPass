//
//  DBManager.swift
//  Hall Pass
//
//  Created by Ali Murad on 11/12/2023.
//

import RealmSwift

class RealmManager {
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

    // Function to add a student to a specific period
    func addStudentToPeriod(periodID: String, studentName: String) {
        if let period = realm.object(ofType: Period.self, forPrimaryKey: periodID) {
            try! realm.write {
                let newStudent = Student()
                newStudent.studentName = studentName
                period.students.append(newStudent)
                // Add the student to the specified period
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
                return period.students
            }
            return nil
        }
}

