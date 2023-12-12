//
//  ViewController.swift
//  Hall Pass
//
//  Created by Ahmad Azam on 08/12/2023.
//

import UIKit
import RealmSwift

protocol SignoutViewCallback: AnyObject {
   func resetView()
}

class StudentViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var periodPickerView: UIPickerView!
    var studentPickerView: UIPickerView!
    @IBOutlet private var periodSelector: UITextField!
    @IBOutlet private var studentSelector: UITextField!
    var periods:  Results<Period>?
    var selectedPeriod: Period?
    var selectedStudent: Student?
    @IBOutlet private var signoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create UIPickerView
        periodPickerView = UIPickerView()
        periodPickerView.translatesAutoresizingMaskIntoConstraints = false
        periodPickerView.delegate = self
        periodPickerView.dataSource = self
        periodSelector.inputView = periodPickerView
        // Create UIPickerView
        studentPickerView = UIPickerView()
        studentPickerView.translatesAutoresizingMaskIntoConstraints = false
        studentPickerView.delegate = self
        studentPickerView.dataSource = self
        studentSelector.inputView = studentPickerView
        self.navigationItem.title = "Students"
        updateButtonStatus()
        studentSelector.delegate = self
        periodSelector.delegate = self
        
        
    }

    
    func updateButtonStatus() {
        let dataFilled = !studentSelector.text.isNilOrEmpty && !periodSelector.text.isNilOrEmpty
        signoutButton.alpha = dataFilled ? 1 : 0.8
        signoutButton.isEnabled = dataFilled
    }
    override func viewWillAppear(_ animated: Bool) {
        periodPickerView.reloadAllComponents()
        studentPickerView.reloadAllComponents()
        periods = RealmManager.shared.getPeriods()
        updateButtonStatus()
    }
    
    @IBAction func actSignOut(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: SignoutViewController.self)) as! SignoutViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.modalPresentationCapturesStatusBarAppearance = true
        vc.signOutDate = Date()
        vc.selectedStudent = selectedStudent
        vc.selectedPeriod = selectedPeriod
        vc.delegate = self
        if let selectedStudent, let selectedPeriod, let signOutDate = vc.signOutDate {
            vc.session = RealmManager.shared.startSession(student: selectedStudent, signOut: signOutDate, period: selectedPeriod)
        }
        self.present(vc, animated: true)
        
    }
    
    // MARK: - UIPickerViewDelegate and UIPickerViewDataSource methods
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
            self.periodSelector.text = selectedPeriod?.periodName
        } else {
            selectedStudent = selectedPeriod?.students[row]
            self.studentSelector.text = selectedStudent?.studentName
        }
        updateButtonStatus()
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



extension StudentViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField.text.isNilOrEmpty else { 
            updateButtonStatus()
            return
        }
        if textField == periodSelector {
            selectedPeriod = periods?.first
            periodSelector.text = selectedPeriod?.periodName
        } else {
            selectedStudent = selectedPeriod?.students.first
            studentSelector.text = selectedStudent?.studentName
        }
        updateButtonStatus()
    }
}

extension StudentViewController: SignoutViewCallback {
    func resetView() {
        updateButtonStatus()
        selectedPeriod = nil
        selectedStudent = nil
        periodSelector.text = ""
        studentSelector.text = ""
        periodPickerView.reloadAllComponents()
        studentPickerView.reloadAllComponents()
        periodPickerView.selectRow(0, inComponent: 0, animated: false)
        studentPickerView.selectRow(0, inComponent: 0, animated: false)
      

    }
}
