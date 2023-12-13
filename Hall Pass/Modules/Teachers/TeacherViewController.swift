//
//  TeacherViewController.swift
//  Break Tracker
//
//  Created by Ali Murad on 11/12/2023.
//

import UIKit

enum Filters {
    case currentMonth
    case lastMonth
    case last6Month
    case thisYear
    case lastYear
}
class TeacherViewController: UITableViewController, PasscodeKitDelegate, UIDocumentInteractionControllerDelegate {
    var documentController: UIDocumentInteractionController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Teacher"
        self.navigationItem.title = "Teacher"
        tableView.delegate = self
        
        
        
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if PasscodeKit.enabled() {
            PasscodeKit().presentPasscodeVerify(self, delegate: self, indexPath.row)
        } else {
            openOption(index: indexPath.row)
        }
        
        
    }
    func passcodeEnteredSuccessfully(index: Int) {
        openOption(index: index)
    }
    
    func openOption(index: Int) {
        switch index{
        case 0:
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: PeriodsViewController.self))
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        case 1: // view
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: ViewSessionsViewController.self))
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        case 2: // download
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showFilters()
            }
            
            
            break;
        default: break;
        }
    }
    
    
    func showFilters() {
        let alert = UIAlertController(title: "Download Pdf", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Current Month", style: .default , handler:{ (_) in
            self.downloadPDF(.currentMonth)
        }))
        
        alert.addAction(UIAlertAction(title: "Previous Month", style: .default , handler:{ (_) in
            self.downloadPDF(.lastYear)
        }))
        
        alert.addAction(UIAlertAction(title: "Last 6 Months", style: .default , handler:{ (_) in
            self.downloadPDF(.last6Month)
        }))
        
        alert.addAction(UIAlertAction(title: "This Year", style: .default, handler:{ (_) in
            self.downloadPDF(.thisYear)
        }))
        
        alert.addAction(UIAlertAction(title: "Last Year", style: .default, handler:{ (_) in
            self.downloadPDF(.lastYear)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view // Set the source view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // Set the source rect
            popoverController.permittedArrowDirections = [] // Optionally set the arrow direction
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func downloadPDF(_ filter: Filters) {
        var filteredSessions: [Session] = []
        
        if let sessions = RealmManager.shared.getSessions() {
            
            switch filter {
            case .currentMonth:
                // Filter sessions for the current month
                let currentDate = Date()
                let calendar = Calendar.current
                let startOfMonth = calendar.startOfDay(for: calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!)
                let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
                
                filteredSessions = sessions.filter { session in
                    return session.signOut >= startOfMonth && session.signOut <= endOfMonth
                }
                
            case .lastMonth:
                // Filter sessions for the last month
                let currentDate = Date()
                let calendar = Calendar.current
                let startOfLastMonth = calendar.date(byAdding: DateComponents(month: -1), to: calendar.startOfDay(for: currentDate))!
                let endOfLastMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfLastMonth)!
                
                filteredSessions = sessions.filter { session in
                    return session.signOut >= startOfLastMonth && session.signOut <= endOfLastMonth
                }
            case .last6Month:
                // Filter sessions for the last 6 months
                let currentDate = Date()
                let calendar = Calendar.current
                guard let startOfLast6Month = calendar.date(byAdding: DateComponents(month: -6), to: calendar.startOfDay(for: currentDate)),
                      let endOfLast6Month = calendar.date(byAdding: DateComponents(day: -1), to: currentDate) else {
                    return
                }
                
                filteredSessions = sessions.filter { session in
                    return session.signOut >= startOfLast6Month && session.signOut <= endOfLast6Month
                }
                
            case .thisYear:
                // Filter sessions for the current year
                let currentDate = Date()
                let calendar = Calendar.current
                let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: currentDate))!
                let endOfYear = calendar.date(byAdding: DateComponents(year: 1, day: -1), to: startOfYear)!
                
                filteredSessions = sessions.filter { session in
                    return session.signOut >= startOfYear && session.signOut <= endOfYear
                }
                
            case .lastYear:
                // Filter sessions for the last year
                let currentDate = Date()
                let calendar = Calendar.current
                let startOfLastYear = calendar.date(byAdding: DateComponents(year: -1), to: calendar.startOfDay(for: currentDate))!
                let endOfLastYear = calendar.date(byAdding: DateComponents(day: -1), to: startOfLastYear)!
                
                filteredSessions = sessions.filter { session in
                    return session.signOut >= startOfLastYear && session.signOut <= endOfLastYear
                }
            }
            
            
        }
        
        
        
        let groupedByDate = Dictionary(grouping: filteredSessions, by: { $0.signOut.startOfDay })
        
        // Create GroupedSession objects and populate groupedSessions
        let groupedSessions = groupedByDate.map { (key, value) in
            let sortedSessions = value.sorted(by: { $0.signOut > $1.signOut })
            return GroupedSession(signOutDate: key, sessions: sortedSessions)
        }.sorted(by: { $0.signOutDate > $1.signOutDate }) // Sort by sign-out date
        if let pdfData = PDFUtil.createPDF(groupedSessions: groupedSessions, appName: Bundle.main.infoDictionary?["CFBundleName"] as! String) {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let pdfURL = documentsDirectory.appendingPathComponent("report.pdf")
            documentController = UIDocumentInteractionController(url: pdfURL)
            documentController.delegate = self
            documentController.presentPreview(animated: true)
            do {
                try pdfData.write(to: pdfURL)
                print("PDF saved at: \(pdfURL)")
            } catch {
                print("Error saving PDF: \(error)")
            }
        } else {
            print("Failed to create PDF")
        }
    }
}

