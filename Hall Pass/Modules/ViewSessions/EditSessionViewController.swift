//
//  EditSessionViewController.swift
//  Break Tracker
//
//  Created by Ali Murad on 17/12/2023.
//

import UIKit
import RealmSwift

protocol EditSessionDelegate: AnyObject {
    func reloadTV()
}
class EditSessionViewController: UIViewController {
    
    @IBOutlet weak var studentText: UITextField!
    @IBOutlet weak var periodText: UITextField!
    @IBOutlet weak var signoutDatePicker: UIDatePicker!
    @IBOutlet weak var signDatePicker: UIDatePicker!
    var periodPickerView: UIPickerView!
    var studentPickerView: UIPickerView!
    var session: Session?
    var selectedPeriod: Period?
    var selectedStudent: Student?
    var periods:  Results<Period>?
    weak var delegate: EditSessionDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let session else { return }
        
        
        selectedPeriod = session.period
        selectedStudent = session.student
        
        studentText.text = session.student?.studentName
        periodText.text = session.period?.periodName
        signoutDatePicker.date = session.signOut
        signDatePicker.date = session.signin
        // Create UIPickerView
        periodPickerView = UIPickerView()
        periodPickerView.translatesAutoresizingMaskIntoConstraints = false
        periodPickerView.delegate = self
        periodPickerView.dataSource = self
        periodText.inputView = periodPickerView
        // Create UIPickerView
        studentPickerView = UIPickerView()
        studentPickerView.translatesAutoresizingMaskIntoConstraints = false
        studentPickerView.delegate = self
        studentPickerView.dataSource = self
        studentText.inputView = studentPickerView
        periodText.delegate = self
        periodText.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        periodPickerView.reloadAllComponents()
        studentPickerView.reloadAllComponents()
        periods = RealmManager.shared.getPeriods()
    }
    
    @IBAction func actionforupdate(_ sender: Any) {
        
            
        if self.signoutDatePicker.date < self.signDatePicker.date {
            self.dismiss(animated: true) {
                let realm = try! Realm()
                try! realm.write {
                    self.session?.signOut = self.signoutDatePicker.date
                    self.session?.signin = self.signDatePicker.date
                    self.session?.period = self.selectedPeriod
                    self.session?.student = self.selectedStudent
                }
                self.delegate?.reloadTV()
            }
        }
            else {
                AlertPresenter.showAlert(on: self, title: "", message: "Sign out date cannot be greater than signin date")
            }
        }
    }

// MARK: - UIPickerViewDelegate and UIPickerViewDataSource methods

extension EditSessionViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if pickerView == periodPickerView {
            if let periods = RealmManager.shared.getPeriods(), row < periods.count {
                let period = periods[row]
                return NSAttributedString(string: period.periodName, attributes: [.foregroundColor: UIColor.accent])
                
            }
        } else {
            if let periodId = selectedPeriod?.id {
                if let students = RealmManager.shared.getStudents(for: periodId) {
                    let student = students[row]
                    return NSAttributedString(string: student.studentName, attributes: [.foregroundColor: UIColor.accent])
                }
            }
        }
        return nil
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == periodPickerView {
            selectedPeriod = periods?[row]
            self.periodText.text = selectedPeriod?.periodName
            studentText.text = ""
            selectedStudent = nil
            studentPickerView.selectRow(0, inComponent: 0, animated: false)
        } else {
            selectedStudent = selectedPeriod?.students[safe: row]
            self.studentText.text = selectedStudent?.studentName
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == periodPickerView {
            return RealmManager.shared.getPeriods()?.count ?? 0
        } else {
            return selectedPeriod?.students.count ?? 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == periodPickerView {
            return periods?[row].periodName
        } else {
            return selectedPeriod?.students[row].studentName
        }
    }
    
}

extension EditSessionViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField.text.isNilOrEmpty else {
            return
        }
        if textField == periodText {
            selectedPeriod = periods?.first
            periodText.text = selectedPeriod?.periodName
        } else {
            selectedStudent = selectedPeriod?.students.first
            studentText.text = selectedStudent?.studentName
        }
    }
}
