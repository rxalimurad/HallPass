//
//  ViewSessionsViewController.swift
//  Break Tracker
//
//  Created by Ali Murad on 12/12/2023.
//

import UIKit
import UIKit
struct GroupedSession {
    let signOutDate: Date
    var sessions: [Session]
}

class ViewSessionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView! // Connect this IBOutlet to your UITableView in Interface Builder
    
    var groupedSessions: [GroupedSession] = [] // Data source for grouped sessions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        // Fetch sessions from Realm or your data source
        if let sessions = RealmManager.shared.getSessions() {
            // Group sessions by sign-out date
            let groupedByDate = Dictionary(grouping: sessions, by: { $0.signOut.startOfDay })
            
            // Create GroupedSession objects and populate groupedSessions
            groupedSessions = groupedByDate.map { (key, value) in
                let sortedSessions = value.sorted(by: { $0.signOut > $1.signOut })
                return GroupedSession(signOutDate: key, sessions: sortedSessions)
            }.sorted(by: { $0.signOutDate > $1.signOutDate }) // Sort by sign-out date
        }
       
        // Set table view delegate and data source
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedSessions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedSessions[section].sessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ViewSessionCell.self), for: indexPath) as! ViewSessionCell
        let session = groupedSessions[indexPath.section].sessions[indexPath.row]
        
        cell.prepareCell(breakTime: session.signOut.minuteDifference(to: session.signin), sigin: session.signin.toTimeString(), signout: session.signOut.toTimeString(), period: session.period?.periodName ?? "N/A", name: session.student?.studentName ?? "N/A")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        groupedSessions[section].signOutDate.toDateString()
    }
    
    // MARK: - UITableViewDelegate
    
    // Add UITableViewDelegate methods as needed
}
