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
        
        // Fetch students for the selected period
        if let period = period {
            students = period.students
        }
        addDBObserver()
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
        let alertController = UIAlertController(title: "Enter Student Name", message: "Please enter student name for \(period?.periodName ?? ""):", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let submitAction = UIAlertAction(title: "Add", style: .default) { (_) in
            if let text = alertController.textFields?.first?.text {
                // Handle the text entered by the user
                print("Entered text: \(text)")
                self.addStudentInDB(name: text)
                
                
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(submitAction)
        
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - UITableViewDataSource
    
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
}
