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
            showFilters()
            
            
            break;
        default: break;
        }
    }
    
    
    func showFilters() {
        let alert = UIAlertController(title: "Download Pdf", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Current Month", style: .default , handler:{ (_) in
            print("User clicked Current Month")
            self.downloadPDF()
        }))
        
        alert.addAction(UIAlertAction(title: "Previous Month", style: .default , handler:{ (_) in
            print("User clicked Previous Month")
        }))
        
        alert.addAction(UIAlertAction(title: "Last 6 Months", style: .default , handler:{ (_) in
            print("User clicked Last 6 Months")
        }))
        
        alert.addAction(UIAlertAction(title: "This Year", style: .default, handler:{ (_) in
            print("User clicked This Year")
        }))
        
        alert.addAction(UIAlertAction(title: "Last Year", style: .default, handler:{ (_) in
            print("User clicked Last Year")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        
         alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true, completion: nil)
    }

    
    func downloadPDF() {
        if let sessions = RealmManager.shared.getSessions() {
            // Group sessions by sign-out date
            let groupedByDate = Dictionary(grouping: sessions, by: { $0.signOut.startOfDay })
            
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
}
