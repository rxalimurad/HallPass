//
//  PeriodDetailsViewController.swift
//  Hall Pass
//
//  Created by Ali Murad on 11/12/2023.
//

import Foundation
import UIKit
import RealmSwift

class PeriodDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    var period: Period?
    var students: List<Student>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up table view delegate and data source
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        let editBtn = UIBarButtonItem(image: UIImage(systemName: "arrow.up.and.down.text.horizontal"), style: .plain, target: self, action: #selector(OnEditButton))
        navigationItem.rightBarButtonItem = editBtn
        // Fetch students for the selected period
        if let period = period {
            students = period.students
        }
        addDBObserver()
    }
    @objc func OnEditButton() {
        tableView.isEditing = !tableView.isEditing
        navigationItem.rightBarButtonItem?.image = tableView.isEditing ? nil : UIImage(systemName: "arrow.up.and.down.text.horizontal")
        navigationItem.rightBarButtonItem?.title = tableView.isEditing ? "Done" : nil
        }
    private func addDBObserver() {
        RealmManager.shared.observeRealmChanges(Period.self) { [weak self] periods in
            self?.tableView.reloadData()
        }
    }
    
    private func addStudentInDB(name: String) {
        RealmManager.shared.addStudentToPeriod(periodID: period?.id ?? "", studentName: name)
    }
    
    @IBAction func addStudentDialog(_ sender: Any) {
        AlertPresenter.showTextFieldAlert(title: "Enter Student Name", message: "Please enter student name for \(period?.periodName ?? ""):", placeholder: "Name", on: self) { text in
            self.addStudentInDB(name: text)
        }
        
    }

    // MARK: - UITableViewDataSource
    

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return tableView.isEditing
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Update the order of periods in your Realm without using an 'order' property
        RealmManager.shared.updateStudentOrder(periodID: period?.id, from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
        
        if let student = students?[indexPath.row] {
            cell.textLabel?.text = student.studentName // Display student name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            AlertPresenter.showConfirmationAlert(on: self, title: "Delete Student", message: "Are you sure you want to delete student?") {
                if let student = self.students?[indexPath.row] {
                    RealmManager.shared.deleteStudent(student: student)
                }
                completionHandler(true)
            }
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in

                if let student = self.students?[safe: indexPath.row] {
                    AlertPresenter.showTextFieldAlert(title: "Update student Name", message: "Please enter student name:", placeholder: "name", text: student.studentName, on: self) { text in
                        RealmManager.shared.updateStudentName(student: student, newName: text)
                    }
                }
            
            
            
            completionHandler(true)
        }
        
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [editAction, deleteAction])
        swipeConfig.performsFirstActionWithFullSwipe = false
        
        return swipeConfig
    }
}
