//
//  TeacherViewController.swift
//  Hall Pass
//
//  Created by Ahmad Azam on 08/12/2023.
//

import UIKit

class PeriodsViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Teacher"
        self.navigationItem.title = "Periods"
        addDBObserver()
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        tableView.dataSource = self
        let editBtn = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(OnEditButton))
        navigationItem.rightBarButtonItem = editBtn
        
        
    }
    @objc func OnEditButton() {
        tableView.isEditing = !tableView.isEditing
        navigationItem.rightBarButtonItem?.title = tableView.isEditing ? "Done" : "Edit"
        }
    
    private func addPeriodInDB(period: String) {
        RealmManager.shared.addPeriod(periodName: period)
    }
    private func addDBObserver() {
        RealmManager.shared.observeRealmChanges(Period.self) { [weak self] periods in
            self?.tableView.reloadData()
        }
    }
    
    @IBAction func addPeriodDialog(_ sender: Any) {
        let alertController = UIAlertController(title: "Enter Period Name", message: "Please enter period name:", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Period"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let submitAction = UIAlertAction(title: "Add", style: .default) { (_) in
            if let text = alertController.textFields?.first?.text {
                // Handle the text entered by the user
                print("Entered text: \(text)")
                self.addPeriodInDB(period: text)
                
                
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(submitAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension PeriodsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeriodCell", for: indexPath)
        
        if let periods = RealmManager.shared.getPeriods(), indexPath.row < periods.count {
            let period = periods[indexPath.row]
            cell.textLabel?.text = period.periodName
        } else {
            cell.textLabel?.text = "No data available"
        }
        
        return cell
    }
    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let periods = RealmManager.shared.getPeriods(), indexPath.row < periods.count {
                RealmManager.shared.deletePeriod(periodID: periods[indexPath.row].id)
            }
        }
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete" 
    }
    


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        RealmManager.shared.getPeriods()?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let periods = RealmManager.shared.getPeriods(), indexPath.row < periods.count {
            let period = periods[indexPath.row]
            let periodDetailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: PeriodDetailsViewController.self)) as! PeriodDetailsViewController
            periodDetailsVC.period = period
            
            periodDetailsVC.title = "Students"
            self.navigationController?.pushViewController(periodDetailsVC, animated: true)
            
        }
        
        
        
    }
}


//MARK:- Programatically View
extension PeriodsViewController {
    
}
