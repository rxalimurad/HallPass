//
//  DateRangeViewController.swift
//  Break Tracker
//
//  Created by Ali Murad on 15/12/2023.
//

import UIKit

class DateRangeViewController: UIViewController {

    @IBOutlet weak var fromDatepicker: UIDatePicker!
    @IBOutlet weak var toDatepicker: UIDatePicker!
    @IBOutlet weak var selectButton: UIButton!
    weak var delegate: UIDocumentInteractionControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set minimum date for toDatepicker as the fromDatepicker's date
        toDatepicker.minimumDate = fromDatepicker.date
        fromDatepicker.maximumDate = Date()
        view.isOpaque = false
        view.backgroundColor = .clear
    }

    @IBAction func fromDateChanged(_ sender: UIDatePicker) {
        // Update minimum date for toDatepicker whenever fromDatepicker changes
        toDatepicker.minimumDate = sender.date
    }

    @IBAction func toDateChanged(_ sender: UIDatePicker) {
        // Update maximum date for fromDatepicker whenever toDatepicker changes
        fromDatepicker.maximumDate = sender.date
    }

    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    func endOfDay(for date: Date) -> Date {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let endOfDay = calendar.date(byAdding: .second, value: -1, to: startOfNextDay)!
        return endOfDay
    }

    @IBAction func didSelectDateRange(_ sender: UIButton) {
        let from = Calendar.current.startOfDay(for:  fromDatepicker.date)
        let to = self.endOfDay(for: toDatepicker.date)

        if from < to {
            // Perform action with the selected date range
            print("Selected date range: \(from) to \(to)")
            dismiss(animated: true) {
                TeacherViewController.downloadPDF(.custom(fromDate: from, toDate: to), delegate: self.delegate)
            }
            
            
            
            
            
        } else {
            // Show an alert indicating the invalid date range
            let alert = UIAlertController(title: "Invalid Date Range",
                                          message: "Please select a 'From' date earlier than the 'To' date.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
 
}
