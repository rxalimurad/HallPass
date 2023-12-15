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
        
        
        
        let editBtn = UIBarButtonItem(image: UIImage(systemName: "arrow.up.and.down.text.horizontal"), style: .plain, target: self, action: #selector(OnEditButton))
        navigationItem.rightBarButtonItem = editBtn
        
        
    }
    @objc func OnEditButton() {
        tableView.isEditing = !tableView.isEditing
        navigationItem.rightBarButtonItem?.image = tableView.isEditing ? nil : UIImage(systemName: "arrow.up.and.down.text.horizontal")
        navigationItem.rightBarButtonItem?.title = tableView.isEditing ? "Done" : nil
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
        AlertPresenter.showTextFieldAlert(title: "Enter Period Name", message: "Please enter period name:", placeholder: "Period", on: self) { text in
            self.addPeriodInDB(period: text)
        }
    }
}

extension PeriodsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return tableView.isEditing
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Update the order of periods in your Realm without using an 'order' property
        RealmManager.shared.updatePeriodsOrder(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            AlertPresenter.showConfirmationAlert(on: self, title: "Delete Period", message: "Are you sure you want to delete Period?") {
                if let periods = RealmManager.shared.getPeriods(), indexPath.row < periods.count {
                    RealmManager.shared.deletePeriod(periodID: periods[indexPath.row].id)
                }
                completionHandler(true)
            }
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
           
            if let periods = RealmManager.shared.getPeriods(), indexPath.row < periods.count {
                let period = periods[indexPath.row]
                AlertPresenter.showTextFieldAlert(title: "Update Period Name", message: "Please enter period name:", placeholder: "Period", text: period.periodName, on: self) { text in
                    RealmManager.shared.updatePeriodName(period: period, newName: text)
                }
            }
            
            
            completionHandler(true)
        }
        
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [editAction, deleteAction])
        swipeConfig.performsFirstActionWithFullSwipe = false
        
        return swipeConfig
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
