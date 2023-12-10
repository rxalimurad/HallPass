//
//  TeacherViewController.swift
//  Hall Pass
//
//  Created by Ahmad Azam on 08/12/2023.
//

import UIKit

class TeacherViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        createAddPeriodView()
        self.title = "Teacher"
        addDBObserver()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func addPeriodInDB(period: String) {
        RealmManager.shared.addPeriod(periodName: period)
    }
    private func addDBObserver() {
        RealmManager.shared.observeRealmChanges(Period.self) { [weak self] periods in
            self?.tableView.reloadData()
        }
    }
     
    @objc func addPeriod() {
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
 
extension TeacherViewController: UITableViewDelegate, UITableViewDataSource {
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        RealmManager.shared.getPeriods()?.count ?? 0
    }
    
}


//MARK:- Programatically View
extension TeacherViewController {
    private func createAddPeriodView() {
        let myBarButtonItem = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(addPeriod))
        navigationItem.rightBarButtonItem = myBarButtonItem


    }
}
