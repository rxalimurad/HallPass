//
//  TeacherViewController.swift
//  Break Tracker
//
//  Created by Ali Murad on 11/12/2023.
//

import UIKit

enum Filters {
    case thisWeek
    case lastWeek
    case last2Weeks
    case currentMonth
    case lastMonth
    case last6Month
    case thisYear
    case lastYear
    case custom(fromDate: Date, toDate: Date)
}
class TeacherViewController: UITableViewController, PasscodeKitDelegate, UIDocumentInteractionControllerDelegate {
    
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
        
        alert.addAction(UIAlertAction(title: "Current Week", style: .default , handler:{ (_) in
            Self.downloadPDF(.thisWeek, delegate: self)
        }))
        alert.addAction(UIAlertAction(title: "Last Week", style: .default , handler:{ (_) in
            Self.downloadPDF(.lastWeek, delegate: self)
        }))
        alert.addAction(UIAlertAction(title: "Last 2 Weeks", style: .default , handler:{ (_) in
            Self.downloadPDF(.last2Weeks, delegate: self)
        }))
        
        alert.addAction(UIAlertAction(title: "Current Month", style: .default , handler:{ (_) in
            Self.downloadPDF(.currentMonth, delegate: self)
        }))
        
        alert.addAction(UIAlertAction(title: "Previous Month", style: .default , handler:{ (_) in
            Self.downloadPDF(.lastMonth, delegate: self)
        }))
        
        alert.addAction(UIAlertAction(title: "Last 6 Months", style: .default , handler:{ (_) in
            Self.downloadPDF(.last6Month, delegate: self)
        }))
        
        alert.addAction(UIAlertAction(title: "This Year", style: .default, handler:{ (_) in
            Self.downloadPDF(.thisYear, delegate: self)
        }))
        
        alert.addAction(UIAlertAction(title: "Last Year", style: .default, handler:{ (_) in
            Self.downloadPDF(.lastYear, delegate: self)
        }))
        
        alert.addAction(UIAlertAction(title: "Custom Date Range", style: .default, handler:{ (_) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: DateRangeViewController.self)) as! DateRangeViewController
            vc.delegate = self
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }))
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view // Set the source view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // Set the source rect
            popoverController.permittedArrowDirections = [] // Optionally set the arrow direction
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    class func downloadPDF(_ filter: Filters, delegate: UIDocumentInteractionControllerDelegate?) {
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
                   guard let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)),
                         let startOfLastMonth = calendar.date(byAdding: DateComponents(month: -1), to: startOfCurrentMonth),
                         let endOfLastMonth = calendar.date(byAdding: DateComponents(day: -1), to: startOfCurrentMonth) else {
                       return
                   }
                
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
            case .thisWeek:
                // Filter sessions for the current week
                let currentDate = Date()
                let calendar = Calendar.current
                guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)),
                      let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) else {
                    return
                }
                
                filteredSessions = sessions.filter { session in
                    return session.signOut >= startOfWeek && session.signOut <= endOfWeek
                }

            case .lastWeek:
                // Filter sessions for the last week
                let currentDate = Date()
                let calendar = Calendar.current
                guard let endOfLastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate),
                      let startOfLastWeek = calendar.date(byAdding: .day, value: -6, to: endOfLastWeek) else {
                    return
                }
                
                filteredSessions = sessions.filter { session in
                    return session.signOut >= startOfLastWeek && session.signOut <= endOfLastWeek
                }

            case .last2Weeks:
                // Filter sessions for the last 2 weeks
                let currentDate = Date()
                let calendar = Calendar.current
                guard let endOfLast2Weeks = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)),
                      let startOfLast2Weeks = calendar.date(byAdding: .day, value: -13, to: endOfLast2Weeks) else {
                    return
                }
                
                filteredSessions = sessions.filter { session in
                    return session.signOut >= startOfLast2Weeks && session.signOut < endOfLast2Weeks
                }
                
            case .custom(fromDate: let fromDate, toDate: let toDate):
                filteredSessions = sessions.filter { session in
                    return session.signOut >= fromDate && session.signOut <= toDate
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
            var documentController = UIDocumentInteractionController(url: pdfURL)
            documentController.delegate = delegate
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

